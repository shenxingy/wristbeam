import XCTest
@testable import WristbeamCore

final class RemoteCommandTests: XCTestCase {
    func testOnlyFreshBoundedGesturesCanCrossBoundary() throws {
        let document = UUID()
        let now: TimeInterval = 1_000
        let valid = RemoteCommand(kind: .scroll, amount: 0.4, documentID: document, sentAt: now)
        let decoded = try JSONDecoder().decode(RemoteCommand.self, from: JSONEncoder().encode(valid))
        XCTAssertTrue(decoded.isValid(at: now))
        XCTAssertFalse(decoded.isValid(at: now + 4))
        XCTAssertFalse(decoded.isValid(at: now - 4))
        XCTAssertFalse(RemoteCommand(kind: .scroll, amount: 1.1, documentID: document, sentAt: now).isValid(at: now))
        XCTAssertFalse(RemoteCommand(kind: .scroll, amount: .infinity, documentID: document, sentAt: now).isValid(at: now))
        XCTAssertFalse(RemoteCommand(kind: .page, amount: 0.5, documentID: document, sentAt: now).isValid(at: now))
        XCTAssertFalse(RemoteCommand(kind: .scroll, amount: 0.5, sentAt: now).isValid(at: now))
        XCTAssertFalse(RemoteCommand(kind: .ping, sentAt: now, version: 2).isValid(at: now))
    }

    func testReplayCannotApplyTheSameGestureTwice() {
        var gate = CommandGate()
        let command = RemoteCommand(kind: .page, amount: 1, documentID: UUID(), sentAt: 100)
        XCTAssertTrue(gate.accept(command, now: 100))
        XCTAssertFalse(gate.accept(command, now: 100.1))
    }

    func testNavigationInputRejectsScriptAndCredentialURLs() {
        XCTAssertEqual(ReaderURL.parse(" example.com/article ")?.absoluteString, "https://example.com/article")
        XCTAssertEqual(ReaderURL.parse("https://example.com/a?q=b")?.host, "example.com")
        for input in ["", "  ", "http://example.com", "javascript:alert(1)", "file:///etc/passwd", "data:text/html,hi",
                      "https://", "https://user:pass@example.com", "example .com"] {
            XCTAssertNil(ReaderURL.parse(input), input)
        }
    }
}
