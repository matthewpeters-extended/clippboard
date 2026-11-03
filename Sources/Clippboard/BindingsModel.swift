import Foundation
import Observation
import ClippboardCore

@MainActor
@Observable
final class BindingsModel {
    private var bindings: Bindings
    var loadError: String?
    let fileURL = URL.applicationSupportDirectory.appending(path: "Clippboard/bindings.json")
    /// Where the app kept bindings before it was renamed from Paste.
    let legacyFileURL = URL.applicationSupportDirectory.appending(path: "Paste/bindings.json")

    var all: [ClippboardCore.Binding] { bindings.all }

    var isPaused: Bool {
        get { bindings.isPaused }
        set { bindings.isPaused = newValue }
    }

    init() {
        do {
            bindings = try Bindings(store: FileBindingStore(url: fileURL, legacyURL: legacyFileURL))
        } catch {
            bindings = Bindings()
            loadError = "Couldn't read your saved Bindings, so none are shown."
        }
    }

    func text(for combo: Combo) -> String? { bindings.text(for: combo) }

    func isDuplicate(_ combo: Combo, excluding id: ClippboardCore.Binding.ID?) -> Bool {
        bindings.all.contains { $0.id != id && $0.combo == combo }
    }

    func save(_ binding: ClippboardCore.Binding) throws {
        if bindings.all.contains(where: { $0.id == binding.id }) {
            try bindings.update(binding)
        } else {
            try bindings.add(binding)
        }
    }

    func delete(_ binding: ClippboardCore.Binding) throws {
        try bindings.remove(id: binding.id)
    }
}
