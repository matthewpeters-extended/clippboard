import Foundation

public protocol BindingStore: Sendable {
    func load() throws -> [Binding]
    func save(_ bindings: [Binding]) throws
}

public final class InMemoryBindingStore: BindingStore, @unchecked Sendable {
    private let lock = NSLock()
    private var saved: [Binding] = []

    public init() {}

    public func load() throws -> [Binding] {
        lock.withLock { saved }
    }

    public func save(_ bindings: [Binding]) throws {
        lock.withLock { saved = bindings }
    }
}

public struct FileBindingStore: BindingStore {
    private let url: URL
    private let legacyURL: URL?

    /// `legacyURL` is where an earlier version kept the file; it is copied to `url` once, if `url` doesn't exist yet.
    public init(url: URL, legacyURL: URL? = nil) {
        self.url = url
        self.legacyURL = legacyURL
    }

    public func load() throws -> [Binding] {
        try migrateLegacyFile()
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return try JSONDecoder().decode([Binding].self, from: Data(contentsOf: url))
    }

    public func save(_ bindings: [Binding]) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(bindings).write(to: url, options: .atomic)
    }

    private func migrateLegacyFile() throws {
        let fm = FileManager.default
        guard let legacyURL, !fm.fileExists(atPath: url.path), fm.fileExists(atPath: legacyURL.path) else { return }
        try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try fm.copyItem(at: legacyURL, to: url)
    }
}
