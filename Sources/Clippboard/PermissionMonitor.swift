import ApplicationServices
import AppKit
import Observation

/// Tracks whether macOS has granted Clippboard the Accessibility permission it needs to see and swallow key presses.
@MainActor
@Observable
final class PermissionMonitor {
    private(set) var isGranted = AXIsProcessTrusted()
    private var timer: Timer?
    /// Called every second with the current permission state, so the owner can start or retry whatever depends on it.
    var onTick: ((Bool) -> Void)?

    init() {
        // There's no notification for this change, so poll cheaply. It lets the notice vanish as soon as it's granted.
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
    }

    private func refresh() {
        let granted = AXIsProcessTrusted()
        if granted != isGranted { isGranted = granted }
        onTick?(granted)
    }

    /// Adds Clippboard to the Accessibility list (so it can be ticked) and opens that Settings pane.
    func requestAndOpenSettings() {
        let promptKey = "AXTrustedCheckOptionPrompt" as CFString
        _ = AXIsProcessTrustedWithOptions([promptKey: true] as CFDictionary)
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
}
