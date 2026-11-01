import PasteCore
import SwiftUI

enum SettingsPage: String, CaseIterable, Identifiable {
    case bindings = "Bindings", general = "General", privacy = "Privacy", account = "Account"

    var id: Self { self }

    var icon: String {
        switch self {
        case .bindings: "keyboard"
        case .general: "gearshape"
        case .privacy: "hand.raised"
        case .account: "person.crop.circle"
        }
    }
}

struct SettingsView: View {
    let model: BindingsModel
    let permission: PermissionMonitor
    let listener: KeyPressListener
    let launchAtLogin: LaunchAtLogin
    let updates: Updates
    @State private var page: SettingsPage? = .bindings

    var body: some View {
        NavigationSplitView {
            List(selection: $page) {
                Section("Use") { sidebarRow(.bindings) }
                Section("General") { sidebarRow(.general); sidebarRow(.privacy) }
                Section("About") { sidebarRow(.account) }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200, max: 240)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text((page ?? .bindings).rawValue).font(.largeTitle.bold())
                    if !permission.isGranted && page != .privacy { PermissionNotice(permission: permission) }
                    else if permission.isGranted && !listener.isRunning { ListenerProblemNotice() }
                    content(for: page ?? .bindings)
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(minWidth: 760, minHeight: 520)
    }

    private func sidebarRow(_ page: SettingsPage) -> some View {
        Label(page.rawValue, systemImage: page.icon).tag(page)
    }

    @ViewBuilder private func content(for page: SettingsPage) -> some View {
        switch page {
        case .bindings: bindingsPage
        case .general: generalPage
        case .privacy: privacyPage
        case .account: accountPage
        }
    }

    // MARK: Pages

    private var bindingsPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsGroup("Pause") {
                SettingsRow("Pause all", detail: "Stops every Binding so your keys behave normally.") {
                    Toggle("Pause all", isOn: Bindable(model).isPaused).labelsHidden().toggleStyle(.switch)
                }
            }
            if model.isPaused { PausedNotice() }

            SettingsGroup("Your Bindings", footer: "A Binding types its Text when you press its Combo in any app, as long as its switch is on and Pause all is off.") {
                BindingsSection(model: model)
                    .padding(14)
            }
        }
    }

    private var generalPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            startupGroup
            updatesGroup
        }
    }

    private var startupGroup: some View {
        SettingsGroup("Startup") {
            SettingsRow("Launch Paste at login", detail: "Start Paste automatically when you log in, so your Bindings always work.") {
                Toggle("Launch Paste at login", isOn: Binding(get: { launchAtLogin.isEnabled }, set: { launchAtLogin.setEnabled($0) }))
                    .labelsHidden().toggleStyle(.switch)
            }
            if let error = launchAtLogin.error {
                Text(error).foregroundStyle(.red).font(.caption).padding(14)
            }
        }
    }

    private var updatesGroup: some View {
        SettingsGroup("Updates", footer: "Paste asks GitHub if a newer version exists. It sends no Bindings or personal data.") {
            SettingsRow("Check for updates automatically", detail: "Looks for a new version of Paste once a day.") {
                Toggle("Check for updates automatically", isOn: Bindable(updates).checksAutomatically)
                    .labelsHidden().toggleStyle(.switch)
            }
            SettingsRow("Check now") {
                Button("Check for Updates") { updates.checkNow() }
            }
        }
    }

    private var privacyPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsGroup("Permission", footer: "macOS needs this so Paste can notice your key combinations in other apps and type for you.") {
                SettingsRow("Accessibility", detail: permission.isGranted ? "Allowed" : "Not allowed. Your Bindings won't fire yet.") {
                    if permission.isGranted {
                        Label("Allowed", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                    } else {
                        Button("Open Settings") { permission.requestAndOpenSettings() }
                    }
                }
            }
            SettingsGroup("Your data") {
                SettingsRow("Network", detail: "Only to check GitHub for updates. Your Bindings never leave this Mac.") {
                    Text(updates.checksAutomatically ? "Update checks" : "Off").foregroundStyle(.secondary)
                }
                SettingsRow("Saved in", detail: model.fileURL.path(percentEncoded: false)) { EmptyView() }
            }
        }
    }

    private var accountPage: some View {
        VStack(alignment: .leading, spacing: 24) {
            SettingsGroup("This Mac", footer: "Paste has no online account. Everything stays on this Mac.") {
                SettingsRow("Mac user") { Text(NSFullUserName()).foregroundStyle(.secondary) }
                SettingsRow("Version") {
                    Text(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev")
                        .foregroundStyle(.secondary)
                }
                SettingsRow("Bindings") { Text("\(model.all.count) saved").foregroundStyle(.secondary) }
            }
            SettingsGroup("Session") {
                SettingsRow("Quit Paste", detail: "Stops Paste. Your Bindings stop working until you open it again.") {
                    Button("Quit Paste", role: .destructive) { NSApplication.shared.terminate(nil) }
                }
            }
        }
    }
}
