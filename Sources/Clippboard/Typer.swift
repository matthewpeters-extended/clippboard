import CoreGraphics
import ClippboardCore

/// Types text into the focused app as characters. Never touches the clipboard.
enum Typer {
    /// Marks events Clippboard posted itself, so the listener never reacts to them.
    static let marker: Int64 = 0x50415354   // "PAST"

    private static let returnKey: CGKeyCode = 36

    static func type(_ text: String) {
        let source = CGEventSource(stateID: .privateState)
        source?.userData = marker
        for step in TypingStep.steps(for: text) {
            switch step {
            case .text(let string): typeCharacters(string, source: source)
            case .newline: post(virtualKey: returnKey, characters: nil, source: source)
            }
        }
    }

    private static func typeCharacters(_ string: String, source: CGEventSource?) {
        let units = Array(string.utf16)
        // Unicode strings on a key event are limited to about 20 UTF-16 units, so send in chunks.
        var start = 0
        while start < units.count {
            var end = min(start + 16, units.count)
            // Don't split a surrogate pair across chunks.
            if end < units.count, UTF16.isLeadSurrogate(units[end - 1]) { end -= 1 }
            post(virtualKey: 0, characters: Array(units[start..<end]), source: source)
            start = end
        }
    }

    private static func post(virtualKey: CGKeyCode, characters: [UniChar]?, source: CGEventSource?) {
        for isDown in [true, false] {
            guard let event = CGEvent(keyboardEventSource: source, virtualKey: virtualKey, keyDown: isDown) else { continue }
            event.flags = []   // the Combo's modifier keys may still be held; don't let them turn this into a different Combo
            if let characters { event.keyboardSetUnicodeString(stringLength: characters.count, unicodeString: characters) }
            event.post(tap: .cgSessionEventTap)
        }
    }
}
