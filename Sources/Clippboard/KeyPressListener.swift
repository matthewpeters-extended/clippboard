import AppKit
@preconcurrency import CoreGraphics
import Observation
import ClippboardCore

/// Watches every key press. When the core says a Combo has Text, the key is swallowed and the Text typed;
/// otherwise the key passes through untouched.
@MainActor
@Observable
final class KeyPressListener {
    @ObservationIgnored private let textFor: (Combo) -> String?
    private var tap: CFMachPort?
    // Kept across stop/start, so a key held through a restart still has its release swallowed.
    @ObservationIgnored private var swallowedKeyCodes: Set<Int64> = []

    init(textFor: @escaping (Combo) -> String?) {
        self.textFor = textFor
    }

    var isRunning: Bool { tap != nil }

    /// Starts listening if the Accessibility permission allows it. Safe to call repeatedly.
    func startIfPossible() {
        guard tap == nil else { return }
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue) | CGEventMask(1 << CGEventType.keyUp.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            let listener = Unmanaged<KeyPressListener>.fromOpaque(refcon!).takeUnretainedValue()
            // The tap is on the main run loop, so this is always the main thread.
            return MainActor.assumeIsolated { listener.handle(type: type, event: event) }
        }
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
            eventsOfInterest: mask, callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else { return }
        CFRunLoopAddSource(CFRunLoopGetMain(), CFMachPortCreateRunLoopSource(nil, tap, 0), .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
        self.tap = tap
    }

    func stop() {
        guard let tap else { return }
        CGEvent.tapEnable(tap: tap, enable: false)
        CFMachPortInvalidate(tap)
        self.tap = nil
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let passThrough = Unmanaged.passUnretained(event)

        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
            return passThrough
        }
        if event.getIntegerValueField(.eventSourceUserData) == Typer.marker { return passThrough }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        if type == .keyUp {
            // Swallow the release of a key whose press we swallowed, so the app never sees half a key press.
            return swallowedKeyCodes.remove(keyCode) != nil ? nil : passThrough
        }

        // Look the Combo up first. The password-field check is a slow system-wide call, so it only runs for a key that is bound.
        guard type == .keyDown, let nsEvent = NSEvent(cgEvent: event), let combo = Combo(event: nsEvent),
              let text = textFor(combo), !PasswordField.isFocused else { return passThrough }

        swallowedKeyCodes.insert(keyCode)
        let isRepeat = event.getIntegerValueField(.keyboardEventAutorepeat) != 0
        if !isRepeat {
            // Type after this event is handled, so we never post from inside the tap callback.
            DispatchQueue.main.async { Typer.type(text) }
        }
        return nil
    }
}
