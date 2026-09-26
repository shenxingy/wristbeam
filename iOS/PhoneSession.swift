import SwiftUI
import WatchConnectivity

@MainActor
final class PhoneSession: NSObject, ObservableObject, WCSessionDelegate {
    @Published private(set) var watchReachable = false
    private weak var reader: ReaderModel?
    private var gate = CommandGate()

    func start(reader: ReaderModel) {
        self.reader = reader
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
                            error: Error?) {
        Task { @MainActor in self.watchReachable = session.isReachable && error == nil }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {
        Task { @MainActor in self.watchReachable = session.isReachable }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in self.watchReachable = false }
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func session(_ session: WCSession, didReceiveMessageData messageData: Data,
                            replyHandler: @escaping (Data) -> Void) {
        guard messageData.count <= 2048,
              let command = try? JSONDecoder().decode(RemoteCommand.self, from: messageData) else {
            replyHandler(Self.encode(RemoteReply(id: nil, status: .invalid)))
            return
        }
        Task { @MainActor in
            guard command.isValid(at: Date().timeIntervalSince1970) else {
                replyHandler(Self.encode(RemoteReply(id: command.id, status: .invalid)))
                return
            }
            guard self.gate.accept(command, now: Date().timeIntervalSince1970) else {
                replyHandler(Self.encode(RemoteReply(id: command.id, status: .duplicate)))
                return
            }
            guard let reader = self.reader else {
                replyHandler(Self.encode(RemoteReply(id: command.id, status: .openReader)))
                return
            }
            reader.apply(command) { reply in replyHandler(Self.encode(reply)) }
        }
    }

    nonisolated private static func encode(_ reply: RemoteReply) -> Data {
        // All reply fields are Codable primitives; positions are checked before construction.
        (try? JSONEncoder().encode(reply)) ?? Data()
    }
}
