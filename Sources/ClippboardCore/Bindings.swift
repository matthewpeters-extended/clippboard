import Foundation

public struct Combo: Hashable, Codable, Sendable {
    public enum Modifier: Hashable, Codable, Sendable { case command, shift, option, control }

    public let key: String
    public let modifiers: Set<Modifier>

    public init(key: String, modifiers: Set<Modifier>) {
        self.key = key
        self.modifiers = modifiers
    }

    /// The Combo as macOS shows it, such as "⇧⌘L".
    public var displayString: String {
        let symbols: [(Modifier, String)] = [(.control, "⌃"), (.option, "⌥"), (.shift, "⇧"), (.command, "⌘")]
        let prefix = symbols.filter { modifiers.contains($0.0) }.map(\.1).joined()
        return prefix + (key.count == 1 ? key.uppercased() : key.prefix(1).uppercased() + key.dropFirst())
    }

    /// What macOS or nearly every app normally does with this Combo, or nil if it's free.
    /// Overriding one is allowed, but the UI should say what is being overridden.
    public var systemUse: String? {
        if modifiers == [.command] { return Self.commandUses[key] }
        if modifiers == [.command, .shift] { return Self.commandShiftUses[key] }
        if modifiers == [.control, .command] { return Self.controlCommandUses[key] }
        return nil
    }

    public var isSystemReserved: Bool { systemUse != nil }

    private static let commandUses: [String: String] = [
        "a": "Select All", "b": "Bold", "c": "Copy", "f": "Find", "g": "Find Next", "h": "Hide the app",
        "i": "Italic", "m": "Minimize the window", "n": "New", "o": "Open", "p": "Print",
        "q": "Quit the app", "r": "Reload", "s": "Save", "t": "New tab", "u": "Underline",
        "v": "Clippboard", "w": "Close the window", "x": "Cut", "z": "Undo", ",": "Open app settings",
        "space": "Spotlight search", "tab": "Switch apps",
    ]

    private static let commandShiftUses: [String: String] = [
        "z": "Redo", "3": "Take a screenshot", "4": "Take a screenshot", "5": "Take a screenshot",
        "g": "Find Previous", "n": "New folder", "t": "Reopen closed tab",
    ]

    private static let controlCommandUses: [String: String] = [
        "q": "Lock the screen", "space": "Emoji picker",
    ]
}

public struct Binding: Equatable, Identifiable, Codable, Sendable {
    public let id: UUID
    public var label: String
    public var combo: Combo
    public var text: String
    public var isEnabled: Bool

    public init(id: UUID = UUID(), label: String, combo: Combo, text: String, isEnabled: Bool = true) {
        self.id = id
        self.label = label
        self.combo = combo
        self.text = text
        self.isEnabled = isEnabled
    }
}

public enum BindingsError: Error, Equatable, Sendable {
    case duplicateCombo
}

public struct Bindings: Sendable {
    public var isPaused = false

    public private(set) var all: [Binding] = []
    private var store: (any BindingStore)?

    public init() {}

    public init(store: any BindingStore) throws {
        self.store = store
        self.all = try store.load()
    }

    public mutating func add(_ binding: Binding) throws {
        guard !all.contains(where: { $0.combo == binding.combo }) else {
            throw BindingsError.duplicateCombo
        }
        all.append(binding)
        try store?.save(all)
    }

    public mutating func update(_ binding: Binding) throws {
        guard let index = all.firstIndex(where: { $0.id == binding.id }) else { return }
        guard !all.contains(where: { $0.id != binding.id && $0.combo == binding.combo }) else {
            throw BindingsError.duplicateCombo
        }
        all[index] = binding
        try store?.save(all)
    }

    public mutating func remove(id: Binding.ID) throws {
        all.removeAll { $0.id == id }
        try store?.save(all)
    }

    public func text(for combo: Combo) -> String? {
        guard !isPaused else { return nil }
        return all.first { $0.combo == combo && $0.isEnabled }?.text
    }
}
