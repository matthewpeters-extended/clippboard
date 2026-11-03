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

    public init(url: URL) {
        self.url = url
    }

    public func load() throws -> [Binding] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return try JSONDecoder().decode([Binding].self, from: Data(contentsOf: url))
    }

    public func save(_ bindings: [Binding]) throws {
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(bindings).write(to: url, options: .atomic)
    }
}
