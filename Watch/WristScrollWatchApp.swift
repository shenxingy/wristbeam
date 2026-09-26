import SwiftUI

@main
@MainActor
struct WristScrollWatchApp: App {
    @StateObject private var remote = WatchRemote()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RemoteView(remote: remote)
                .onChange(of: scenePhase) { _, phase in remote.setActive(phase == .active) }
                .task {
                    remote.setActive(scenePhase == .active)
                    while !Task.isCancelled {
                        do { try await Task.sleep(nanoseconds: 2_000_000_000) } catch { return }
                        if scenePhase == .active { remote.synchronize() }
                    }
                }
        }
    }
}

@MainActor
struct RemoteView: View {
    @ObservedObject var remote: WatchRemote
    @State private var crown = 0.0

    var body: some View {
        VStack(spacing: 8) {
            Text("WristScroll").font(.headline)
            Text(LocalizedStringKey(remote.statusKey))
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if remote.ready {
                HStack(spacing: 8) {
                    Button { remote.page(-1) } label: {
                        Image(systemName: "arrow.up").frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityLabel(Text("remote.previous"))
                    Button { remote.page(1) } label: {
                        Image(systemName: "arrow.down").frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .accessibilityLabel(Text("remote.next"))
                }
                .buttonStyle(.bordered)
                .disabled(remote.isSending)
                Text("remote.crownHint").font(.caption2).foregroundStyle(.secondary)
                if let position = remote.position {
                    ProgressView(value: position)
                        .accessibilityLabel(Text("remote.progress"))
                        .accessibilityValue(Text(position, format: .percent.precision(.fractionLength(0))))
                }
            } else {
                Button("remote.retry") { remote.synchronize() }
                    .buttonStyle(.borderedProminent)
                    .disabled(remote.isSending)
            }
        }
        .padding(.horizontal, 8)
        .focusable(true)
        .digitalCrownRotation($crown, from: -100_000, through: 100_000, by: 0.1,
                              sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: false)
        .onChange(of: crown) { old, new in remote.crownChanged(by: new - old) }
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: remote.page(1)
            case .decrement: remote.page(-1)
            @unknown default: break
            }
        }
    }
}
