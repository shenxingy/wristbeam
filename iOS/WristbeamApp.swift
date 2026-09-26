import SwiftUI
import WebKit

@main
@MainActor
struct WristbeamApp: App {
    @StateObject private var reader = ReaderModel()
    @StateObject private var connection = PhoneSession()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ReaderView(reader: reader, connection: connection)
                .task {
                    connection.start(reader: reader)
                    if !reader.hasDocument && !reader.isLoading { reader.loadDemo() }
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { reader.updateIdleTimer() }
                    else { UIApplication.shared.isIdleTimerDisabled = false }
                }
        }
    }
}

@MainActor
struct ReaderView: View {
    @ObservedObject var reader: ReaderModel
    @ObservedObject var connection: PhoneSession
    @State private var address = ""
    @State private var showHelp = false
    @FocusState private var editingAddress: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    TextField("reader.address", text: $address)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.go)
                        .textFieldStyle(.roundedBorder)
                        .focused($editingAddress)
                        .onSubmit(openAddress)
                        .accessibilityLabel(Text("reader.address"))
                    Button(action: openAddress) {
                        Image(systemName: "arrow.right")
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .accessibilityLabel(Text("reader.open"))
                    .disabled(address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 16)
                ProgressView().opacity(reader.isLoading ? 1 : 0).frame(height: 8)
                    .accessibilityHidden(!reader.isLoading)
                if let error = reader.errorKey {
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey(error)).font(.callout)
                        HStack {
                            Button("reader.retry") { reader.reload() }
                            Button("reader.demo") { reader.loadDemo() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(16)
                }
                WebReader(webView: reader.webView)
                VStack(spacing: 8) {
                    Label {
                        Text(LocalizedStringKey(connection.watchReachable ? "reader.watchConnected" : "reader.openWatch"))
                    } icon: {
                        Image(systemName: connection.watchReachable ? "applewatch" : "applewatch.slash")
                    }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        Button { reader.goBack() } label: {
                            Image(systemName: "chevron.left").frame(minWidth: 44, minHeight: 44)
                        }
                        .disabled(!reader.canGoBack)
                        .accessibilityLabel(Text("reader.back"))
                        Spacer()
                        Button { reader.localPage(-1) } label: {
                            Image(systemName: "arrow.up").frame(minWidth: 44, minHeight: 44)
                        }
                        .accessibilityLabel(Text("remote.previous"))
                        .disabled(!reader.hasDocument || reader.isLoading)
                        Button { reader.localPage(1) } label: {
                            Image(systemName: "arrow.down").frame(minWidth: 44, minHeight: 44)
                        }
                        .accessibilityLabel(Text("remote.next"))
                        .disabled(!reader.hasDocument || reader.isLoading)
                    }
                }
                .padding(.horizontal, 16)
                .background(.bar)
            }
            .navigationTitle(reader.pageName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showHelp = true } label: { Image(systemName: "info.circle") }
                        .accessibilityLabel(Text("reader.help"))
                }
            }
            .sheet(isPresented: $showHelp) {
                NavigationStack {
                    Form {
                        Section("reader.howTo") {
                            Text("reader.helpBody")
                            Button("reader.demo") { reader.loadDemo(); showHelp = false }
                        }
                        Section {
                            Toggle("reader.keepAwake", isOn: $reader.keepAwake)
                        } footer: { Text("reader.keepAwakeHint") }
                        Section("reader.scope") { Text("reader.scopeBody") }
                    }
                    .navigationTitle(Text("reader.help"))
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("reader.done") { showHelp = false }
                        }
                    }
                }
            }
        }
    }

    private func openAddress() {
        editingAddress = false
        reader.open(address)
    }
}

struct WebReader: UIViewRepresentable {
    let webView: WKWebView
    func makeUIView(context: Context) -> WKWebView { webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
