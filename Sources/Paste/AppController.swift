import Foundation

/// Owns the pieces that have to exist from launch, before the popover is ever opened.
@MainActor
final class AppController {
    let model = BindingsModel()
    let permission = PermissionMonitor()
    let launchAtLogin = LaunchAtLogin()
    let updates = Updates()
    let listener: KeyPressListener

    init() {
        let model = model
        let listener = KeyPressListener { combo in model.text(for: combo) }
        self.listener = listener
        // Every tick: while permission is granted keep trying to listen (so a failed start recovers), otherwise stop.
        permission.onTick = { granted in
            if granted { listener.startIfPossible() } else { listener.stop() }
        }
        if permission.isGranted { listener.startIfPossible() }
    }
}
