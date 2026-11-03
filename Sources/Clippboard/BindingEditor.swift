import ClippboardCore
import SwiftUI

struct BindingEditor: View {
    let model: BindingsModel
    let original: ClippboardCore.Binding?
    let done: () -> Void

    @State private var label: String
    @State private var combo: Combo?
    @State private var text: String
    @State private var saveError: String?

    init(model: BindingsModel, original: ClippboardCore.Binding?, done: @escaping () -> Void) {
        self.model = model
        self.original = original
        self.done = done
        _label = State(initialValue: original?.label ?? "")
        _combo = State(initialValue: original?.combo)
        _text = State(initialValue: original?.text ?? "")
    }

    private var isDuplicate: Bool {
        combo.map { model.isDuplicate($0, excluding: original?.id) } ?? false
    }

    private var canSave: Bool {
        !label.trimmingCharacters(in: .whitespaces).isEmpty && combo != nil && !text.isEmpty && !isDuplicate
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Label, e.g. Postal code", text: $label)
            KeyRecorderField(combo: $combo)
            if isDuplicate {
                Label("Another Binding already uses \(combo?.displayString ?? "this Combo").", systemImage: "xmark.octagon.fill")
                    .foregroundStyle(.red).font(.caption)
            } else if let combo, let use = combo.systemUse {
                Label("\(combo.displayString) is normally “\(use)”. Saving overrides it in every app while Clippboard is on. Pause Clippboard to get it back.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange).font(.caption)
            }
            TextField("Text to type", text: $text, axis: .vertical)
                .lineLimit(1...4)
            if let saveError {
                Text(saveError).foregroundStyle(.red).font(.caption)
            }
            HStack {
                Spacer()
                Button("Cancel", action: done)
                Button("Save", action: save).disabled(!canSave).keyboardShortcut(.defaultAction)
            }
        }
        .textFieldStyle(.roundedBorder)
    }

    private func save() {
        guard let combo else { return }
        let binding = ClippboardCore.Binding(
            id: original?.id ?? UUID(), label: label.trimmingCharacters(in: .whitespaces),
            combo: combo, text: text, isEnabled: original?.isEnabled ?? true)
        do {
            try model.save(binding)
            done()
        } catch BindingsError.duplicateCombo {
            saveError = "Another Binding already uses that Combo."
        } catch {
            saveError = "Couldn't save: \(error.localizedDescription)"
        }
    }
}
