import SwiftUI
import WebKit

@MainActor
final class ReaderModel: NSObject, ObservableObject, WKNavigationDelegate {
    let webView: WKWebView
    @Published private(set) var isLoading = false
    @Published private(set) var hasDocument = false
    @Published private(set) var errorKey: String?
    @Published private(set) var canGoBack = false
    @Published private(set) var pageName = "Wristbeam"
    @Published var keepAwake = false {
        didSet { updateIdleTimer() }
    }
    private(set) var documentID = UUID()
    private let engineAvailable: Bool

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        if let file = Bundle.main.url(forResource: "scroll-controller", withExtension: "js"),
           let source = try? String(contentsOf: file, encoding: .utf8) {
            configuration.userContentController.addUserScript(WKUserScript(
                source: source, injectionTime: .atDocumentEnd,
                forMainFrameOnly: true, in: .defaultClient
            ))
            engineAvailable = true
        } else {
            engineAvailable = false
        }
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
    }

    func open(_ text: String) {
        guard let url = ReaderURL.parse(text) else {
            errorKey = "reader.invalidURL"
            return
        }
        errorKey = nil
        webView.load(URLRequest(url: url))
    }

    func loadDemo() {
        guard let url = Bundle.main.url(forResource: "demo", withExtension: "html"),
              let html = try? String(contentsOf: url, encoding: .utf8) else {
            errorKey = "reader.missingResources"
            return
        }
        webView.loadHTMLString(html, baseURL: nil)
    }

    func goBack() { webView.goBack() }
    func reload() { webView.reload() }
    func clearError() { errorKey = nil }

    func updateIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = keepAwake && UIApplication.shared.applicationState == .active
    }

    func apply(_ command: RemoteCommand, completion: @escaping (RemoteReply) -> Void) {
        func reply(_ status: RemoteReply.Status, position: Double? = nil) {
            completion(RemoteReply(id: command.id, status: status, documentID: documentID, position: position))
        }
        guard UIApplication.shared.applicationState == .active else { reply(.openReader); return }
        guard engineAvailable else { reply(.failed); return }
        guard hasDocument, !isLoading else { reply(.loading); return }
        if command.kind == .ping { reply(.ready); return }
        guard command.documentID == documentID, command.isValid(at: Date().timeIntervalSince1970) else {
            reply(.stale); return
        }
        let expectedDocument = documentID
        // Arguments are structured values, never interpolated into JavaScript source.
        webView.callAsyncJavaScript(
            "return globalThis.wristbeamScroll(command);",
            arguments: ["command": ["kind": command.kind.rawValue, "amount": command.amount]],
            in: nil, in: .defaultClient
        ) { [weak self] result in
            guard let self else { completion(RemoteReply(id: command.id, status: .failed)); return }
            guard self.documentID == expectedDocument, !self.isLoading else {
                reply(.stale); return
            }
            guard case .success(let value) = result,
                  let response = value as? [String: Any], response["ok"] as? Bool == true,
                  let position = response["position"] as? Double,
                  position.isFinite, (0...1).contains(position) else {
                reply(.failed); return
            }
            reply(response["moved"] as? Bool == true ? .moved : .boundary, position: position)
        }
    }

    func localPage(_ amount: Double) {
        apply(RemoteCommand(kind: .page, amount: amount, documentID: documentID)) { [weak self] reply in
            if reply.status == .failed { self?.errorKey = "reader.scrollFailed" }
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        documentID = UUID()
        isLoading = true
        hasDocument = false
        errorKey = nil
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false
        hasDocument = engineAvailable
        canGoBack = webView.canGoBack
        pageName = webView.url?.host ?? "Wristbeam"
        if !engineAvailable { errorKey = "reader.missingResources" }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        failed(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        failed(error)
    }

    private func failed(_ error: Error) {
        if (error as NSError).code == NSURLErrorCancelled { return }
        isLoading = false
        hasDocument = false
        errorKey = "reader.loadFailed"
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        documentID = UUID()
        hasDocument = false
        isLoading = false
        errorKey = "reader.loadFailed"
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        let permitted = url.absoluteString == "about:blank" || ReaderURL.parse(url.absoluteString) != nil
        guard permitted else {
            if navigationAction.targetFrame?.isMainFrame != false { errorKey = "reader.unsupportedLink" }
            decisionHandler(.cancel)
            return
        }
        // Open target=_blank links in the existing reader instead of silently losing them.
        if navigationAction.targetFrame == nil {
            decisionHandler(.cancel)
            webView.load(navigationAction.request)
            return
        }
        decisionHandler(.allow)
    }
}
