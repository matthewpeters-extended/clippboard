import ClippboardCore
import SwiftUI

struct PopoverView: View {
    let model: BindingsModel
    let permission: PermissionMonitor
    let listener: KeyPressListener
    @AppStorage(DefaultsKey.hasSeenWelcome) private var hasSeenWelcome = false
    @Environment(\.openWindow) private var openWindow

    var body: some View { main }

    private var main: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !hasSeenWelcome {
                Button("Finish setting up Clippboard", systemImage: "sparkles") { openWelcome() }
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if !permission.isGranted { PermissionNotice(permission: permission) }
            else if !listener.isRunning { ListenerProblemNotice() }

            HStack {
                Text("Clippboard").font(.headline)
                Spacer()
                Toggle("Pause all", isOn: Bindable(model).isPaused).toggleStyle(.switch)
            }
            if model.isPaused { PausedNotice() }

            BindingsSection(model: model)

            Divider()
            Button("Settings", systemImage: "gearshape") { openSettings() }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .frame(width: 320)
        .containerShape(.rect(cornerRadius: 24))
    }

    private func openWelcome() {
        NSApp.keyWindow?.close()
        openWindow(id: "welcome")
        NSApp.activate()
    }

    private func openSettings() {
        NSApp.keyWindow?.close()   // dismiss the popover
        openWindow(id: "settings")
        NSApp.activate()
    }
}
