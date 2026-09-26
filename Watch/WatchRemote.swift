import SwiftUI
import WatchConnectivity

@MainActor
final class WatchRemote: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var ready = false
    @Published private(set) var isSending = false
    @Published private(set) var statusKey = "remote.connecting"
    @Published private(set) var position: Double?
    private var documentID: UUID?
    private var inFlight: UUID?
    private var pendingScroll = 0.0
    private var active = false
    private var timeout: Task<Void, Never>?
    private var throttle: Task<Void, Never>?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        } else { statusKey = "remote.unavailable" }
    }

    func setActive(_ value: Bool) {
        active = value
        if value { synchronize() }
        else { reset("remote.paused") }
    }

    func synchronize() {
        guard active, inFlight == nil else { return }
        send(RemoteCommand(kind: .ping))
    }

    func page(_ direction: Double) {
        guard ready, !isSending, active else { return }
        pendingScroll = 0
        throttle?.cancel()
        throttle = nil
        send(RemoteCommand(kind: .page, amount: direction, documentID: documentID))
    }

    func crownChanged(by delta: Double) {
        guard active, ready, delta.isFinite else { return }
        // Coalesce high-frequency Crown changes; at most one live command in flight.
        pendingScroll = max(-1, min(1, pendingScroll + delta * 0.35))
        scheduleScroll()
    }

    private func scheduleScroll() {
        guard throttle == nil, inFlight == nil, abs(pendingScroll) > 0.001 else { return }
        throttle = Task { @MainActor [weak self] in
            do { try await Task.sleep(nanoseconds: 60_000_000) } catch { return }
            guard let self else { return }
            self.throttle = nil
            guard self.active, self.ready, self.inFlight == nil else {
                self.pendingScroll = 0
                return
            }
            let amount = self.pendingScroll
            self.pendingScroll = 0
            self.send(RemoteCommand(kind: .scroll, amount: amount, documentID: self.documentID))
        }
    }

    private func send(_ command: RemoteCommand) {
        guard active, inFlight == nil else { return }
        let session = WCSession.default
        guard session.activationState == .activated, session.isReachable else {
            reset("remote.disconnected")
            return
        }
        guard let data = try? JSONEncoder().encode(command) else { reset("remote.failed"); return }
        inFlight = command.id
        isSending = true
        timeout?.cancel()
        timeout = Task { @MainActor [weak self] in
            do { try await Task.sleep(nanoseconds: 1_500_000_000) } catch { return }
            guard let self, self.inFlight == command.id else { return }
            self.reset("remote.timeout")
        }
        session.sendMessageData(data, replyHandler: { [weak self] data in
            Task { @MainActor in self?.receive(data, for: command.id) }
        }, errorHandler: { [weak self] _ in
            Task { @MainActor in
                guard let self, self.inFlight == command.id else { return }
                self.reset("remote.disconnected")
            }
        })
    }

    private func receive(_ data: Data, for id: UUID) {
        guard active, inFlight == id else { return }
        timeout?.cancel()
        timeout = nil
        inFlight = nil
        isSending = false
        guard data.count <= 2048,
              let reply = try? JSONDecoder().decode(RemoteReply.self, from: data),
              reply.id == id else { reset("remote.failed"); return }
        let previousDocument = documentID
        documentID = reply.documentID
        ready = reply.canScroll
        if previousDocument != documentID {
            pendingScroll = 0
            position = nil
        }
        if let progress = reply.position, progress.isFinite, (0...1).contains(progress) {
            position = progress
        }
        switch reply.status {
        case .ready, .moved: statusKey = "remote.ready"
        case .boundary: statusKey = "remote.boundary"
        case .openReader: statusKey = "remote.openReader"
        case .loading: statusKey = "remote.loading"
        case .stale: statusKey = "remote.pageChanged"
        case .invalid, .duplicate, .failed: statusKey = "remote.failed"
        }
        if !ready { pendingScroll = 0 }
        else { scheduleScroll() }
    }

    private func reset(_ key: String) {
        timeout?.cancel()
        throttle?.cancel()
        timeout = nil
        throttle = nil
        inFlight = nil
        pendingScroll = 0
        ready = false
        isSending = false
        documentID = nil
        position = nil
        statusKey = key
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                            error: Error?) {
        Task { @MainActor in
            if error != nil { self.reset("remote.disconnected") }
            else { self.synchronize() }
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in
            if session.isReachable { self.synchronize() }
            else { self.reset("remote.disconnected") }
        }
    }
}
