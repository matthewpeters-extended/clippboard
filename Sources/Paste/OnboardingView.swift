import SwiftUI

/// First-run welcome: allow the one permission Paste needs, choose startup, then point at the menu bar icon.
struct OnboardingView: View {
    let permission: PermissionMonitor
    let launchAtLogin: LaunchAtLogin
    @AppStorage(DefaultsKey.hasSeenWelcome) private var hasSeenWelcome = false
    @Environment(\.dismiss) private var dismiss
    @State private var startAtLogin = true

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Welcome to Paste").font(.largeTitle.bold())
                Text("Attach your own text to a key combination, then press it in any app to type the text for you.")
                    .foregroundStyle(.secondary)
            }

            SettingsGroup("1. Allow Accessibility",
                          footer: "macOS requires this so Paste can notice your key combinations in other apps and type for you. It's the only permission Paste needs. Paste only goes online to check GitHub for updates (you can turn that off in Settings), and never touches your clipboard. In the list, turn on Paste. If it isn't listed, click + and choose Paste.") {
                SettingsRow("Accessibility", detail: permission.isGranted ? "Allowed. You're set." : "Not allowed yet.") {
                    if permission.isGranted {
                        Label("Allowed", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                    } else {
                        Button("Open Accessibility Settings") { permission.requestAndOpenSettings() }
                            .keyboardShortcut(.defaultAction)
                    }
                }
            }

            SettingsGroup("2. Start with your Mac") {
                SettingsRow("Launch Paste at login", detail: "So your Bindings are always ready. You can change this later in Settings.") {
                    Toggle("Launch Paste at login", isOn: $startAtLogin).labelsHidden().toggleStyle(.switch)
                }
            }

            SettingsGroup("3. Add your first Binding") {
                SettingsRow("Click the Paste icon in the menu bar", detail: "Then choose Add Binding, pick a key combination and type the text it should produce.") {
                    Image(systemName: "doc.on.clipboard").foregroundStyle(.secondary)
                }
            }

            HStack {
                if !permission.isGranted {
                    Text("Bindings won't type until Accessibility is allowed.").font(.caption).foregroundStyle(.orange)
                }
                Spacer()
                Button("Done", action: finish)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(permission.isGranted ? .defaultAction : nil)
            }
        }
        .padding(28)
        .frame(width: 560)
    }

    private func finish() {
        launchAtLogin.setEnabled(startAtLogin)
        hasSeenWelcome = true
        dismiss()
    }
}
