import SwiftUI

@main
struct ClippboardApp: App {
    @State private var controller = AppController()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(model: controller.model, permission: controller.permission, listener: controller.listener)
        } label: {
            MenuBarIcon(model: controller.model)
        }
        .menuBarExtraStyle(.window)

        Window("Clippboard Settings", id: "settings") {
            SettingsView(model: controller.model, permission: controller.permission, listener: controller.listener, launchAtLogin: controller.launchAtLogin, updates: controller.updates)
        }
        .windowResizability(.contentMinSize)
        .defaultLaunchBehavior(.suppressed)

        Window("Welcome to Clippboard", id: "welcome") {
            OnboardingView(permission: controller.permission, launchAtLogin: controller.launchAtLogin)
        }
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)
    }
}

/// The menu bar icon. It is on screen from launch, so it is also where the first-run welcome window gets opened.
private struct MenuBarIcon: View {
    let model: BindingsModel
    @AppStorage(DefaultsKey.hasSeenWelcome) private var hasSeenWelcome = false
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Image(systemName: model.isPaused ? "pause.circle" : "doc.on.clipboard")
            .onAppear {
                guard !hasSeenWelcome else { return }
                openWindow(id: "welcome")
                NSApp.activate()
            }
    }
}
