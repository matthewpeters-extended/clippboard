import AppKit
import ClippboardCore

/// How a key press is named as a Combo. Shared by the recorder and the listener so they always agree.
extension Combo {
    static func modifiers(of event: NSEvent) -> Set<Combo.Modifier> {
        var result: Set<Combo.Modifier> = []
        let flags = event.modifierFlags
        if flags.contains(.command) { result.insert(.command) }
        if flags.contains(.shift) { result.insert(.shift) }
        if flags.contains(.option) { result.insert(.option) }
        if flags.contains(.control) { result.insert(.control) }
        return result
    }

    private static let namedKeys: [UInt16: String] = [
        36: "return", 48: "tab", 49: "space", 51: "delete", 117: "forwarddelete",
        123: "left", 124: "right", 125: "down", 126: "up",
        115: "home", 119: "end", 116: "pageup", 121: "pagedown",
        122: "f1", 120: "f2", 99: "f3", 118: "f4", 96: "f5", 97: "f6",
        98: "f7", 100: "f8", 101: "f9", 109: "f10", 103: "f11", 111: "f12",
    ]

    static func keyName(of event: NSEvent) -> String? {
        if let named = namedKeys[event.keyCode] { return named }
        // Name the key as if no modifiers were held, so Shift+3 is "3" (not "#") and matches the system-Combo list.
        guard let chars = event.characters(byApplyingModifiers: [])?.lowercased(), chars.count == 1 else { return nil }
        return chars
    }
}

extension Combo {
    init?(event: NSEvent) {
        guard let key = Combo.keyName(of: event) else { return nil }
        self.init(key: key, modifiers: Combo.modifiers(of: event))
    }
}
