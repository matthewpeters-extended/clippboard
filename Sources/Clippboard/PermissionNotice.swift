import SwiftUI

/// Shown at the top of the popover while the permission is missing.
struct PermissionNotice: View {
    let permission: PermissionMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Clippboard needs Accessibility permission, so your Bindings won't fire yet.", systemImage: "exclamationmark.triangle.fill")
                .font(.caption).foregroundStyle(.orange)
            Button("Open Accessibility Settings") { permission.requestAndOpenSettings() }
                .controlSize(.small)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.15), in: ConcentricRectangle())
    }
}

/// Shown when Accessibility is allowed but Clippboard still couldn't start listening for keys. Clippboard keeps retrying.
struct ListenerProblemNotice: View {
    var body: some View {
        Label("Clippboard can't listen for keys right now, so your Bindings won't fire. It keeps retrying. If this stays, remove Clippboard from the Accessibility list, add it again and reopen Clippboard.", systemImage: "exclamationmark.triangle.fill")
            .font(.caption).foregroundStyle(.orange)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.orange.opacity(0.15), in: ConcentricRectangle())
    }
}
