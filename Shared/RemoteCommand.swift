import Foundation

/// Only live reading gestures cross the device boundary. No URLs or page text.
public struct RemoteCommand: Codable, Equatable {
    public enum Kind: String, Codable { case ping, scroll, page }
    public let version: Int
    public let id: UUID
    public let sentAt: TimeInterval
    public let kind: Kind
    public let amount: Double
    public let documentID: UUID?

    public init(kind: Kind, amount: Double = 0, documentID: UUID? = nil,
                id: UUID = UUID(), sentAt: TimeInterval = Date().timeIntervalSince1970,
                version: Int = 1) {
        self.version = version
        self.id = id
        self.sentAt = sentAt
        self.kind = kind
        self.amount = amount
        self.documentID = documentID
    }

    public func isValid(at now: TimeInterval) -> Bool {
        guard version == 1, sentAt.isFinite, amount.isFinite,
              abs(now - sentAt) <= 3 else { return false }
        switch kind {
        case .ping: return amount == 0
        case .scroll: return documentID != nil && abs(amount) <= 1
        case .page: return documentID != nil && abs(amount) == 1
        }
    }
}

public struct RemoteReply: Codable {
    public enum Status: String, Codable {
        case ready, moved, boundary, openReader, loading, stale, invalid, duplicate, failed
    }
    public let id: UUID?
    public let status: Status
    public let documentID: UUID?
    public let position: Double?

    public init(id: UUID?, status: Status, documentID: UUID? = nil, position: Double? = nil) {
        self.id = id
        self.status = status
        self.documentID = documentID
        self.position = position
    }

    public var canScroll: Bool {
        [.ready, .moved, .boundary].contains(status) && documentID != nil
    }
}

/// Bound memory and reject duplicate IDs, including those still being applied.
public struct CommandGate {
    private var recent: [UUID] = []
    public init() {}
    public mutating func accept(_ command: RemoteCommand, now: TimeInterval) -> Bool {
        guard command.isValid(at: now), !recent.contains(command.id) else { return false }
        recent.append(command.id)
        if recent.count > 128 { recent.removeFirst(recent.count - 128) }
        return true
    }
}

public enum ReaderURL {
    /// HTTPS is the default; never treat script, file, or deep-link schemes as pages.
    public static func parse(_ text: String) -> URL? {
        let input = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !input.isEmpty, !input.contains(where: { $0.isWhitespace }) else { return nil }
        let candidate = input.contains(":") ? input : "https://" + input
        guard let components = URLComponents(string: candidate),
              components.scheme?.lowercased() == "https",
              let host = components.host, !host.isEmpty,
              components.user == nil, components.password == nil else { return nil }
        return components.url
    }
}
