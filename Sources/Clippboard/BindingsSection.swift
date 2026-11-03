import ClippboardCore
import SwiftUI

/// The Bindings list and the add/edit form. Shared by the popover and the Settings window.
struct BindingsSection: View {
    let model: BindingsModel
    @State private var editing: ClippboardCore.Binding?
    @State private var isAdding = false
    @State private var actionError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let error = model.loadError ?? actionError {
                Text(error).foregroundStyle(.red).font(.caption)
            }

            if isAdding {
                BindingEditor(model: model, original: nil) { isAdding = false }
            } else if let editing {
                BindingEditor(model: model, original: editing) { self.editing = nil }
                    .id(editing.id)
            } else {
                list
                Button("Add Binding", systemImage: "plus") { isAdding = true }
            }
        }
    }

    @ViewBuilder private var list: some View {
        if model.all.isEmpty {
            Text("No Bindings yet")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(.quaternary, in: ConcentricRectangle())
        } else {
            VStack(spacing: 6) {
                ForEach(model.all) { binding in
                    row(binding)
                }
            }
        }
    }

    private func row(_ binding: ClippboardCore.Binding) -> some View {
        HStack {
            Toggle("On", isOn: Binding(get: { binding.isEnabled }, set: { on in
                var changed = binding
                changed.isEnabled = on
                attempt { try model.save(changed) }
            })).labelsHidden().toggleStyle(.switch).controlSize(.small)
            VStack(alignment: .leading, spacing: 0) {
                Text(binding.label)
                Text(binding.combo.displayString).font(.caption).foregroundStyle(.secondary)
            }
            .opacity(binding.isEnabled ? 1 : 0.5)
            Spacer()
            Button("Edit", systemImage: "pencil") { editing = binding }
            Button("Delete", systemImage: "trash") { attempt { try model.delete(binding) } }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .padding(8)
        .background(.quaternary, in: ConcentricRectangle())
    }

    private func attempt(_ action: () throws -> Void) {
        do { try action(); actionError = nil } catch { actionError = "Couldn't save: \(error.localizedDescription)" }
    }
}

struct PausedNotice: View {
    var body: some View {
        Label("Paused: every key works normally. Turn off Pause all to use your Bindings.", systemImage: "pause.circle.fill")
            .font(.caption).foregroundStyle(.orange)
    }
}
