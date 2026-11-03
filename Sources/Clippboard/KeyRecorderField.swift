import AppKit
import ClippboardCore
import SwiftUI

/// A "press the keys you want" field. Click it to record; Escape cancels.
struct KeyRecorderField: View {
    @SwiftUI.Binding var combo: Combo?
    @State private var isRecording = false

    var body: some View {
        HStack(spacing: 8) {
            Button {
                isRecording.toggle()
            } label: {
                Text(label)
                    .foregroundStyle(combo == nil && !isRecording ? .secondary : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .background(isRecording ? AnyShapeStyle(.tint.opacity(0.25)) : AnyShapeStyle(.quaternary), in: ConcentricRectangle())
            }
            .buttonStyle(.plain)
            .overlay { KeyCapture(isRecording: $isRecording, combo: $combo).allowsHitTesting(false) }

            if combo != nil {
                Button("Clear") { combo = nil; isRecording = false }
            }
        }
        .containerShape(.rect(cornerRadius: 10))
    }

    private var label: String {
        if isRecording { return "Press a key with ⌘ ⌥ ⌃ or ⇧…" }
        return combo?.displayString ?? "Click to record"
    }
}

private struct KeyCapture: NSViewRepresentable {
    @SwiftUI.Binding var isRecording: Bool
    @SwiftUI.Binding var combo: Combo?

    func makeNSView(context: Context) -> CaptureView { CaptureView() }

    func updateNSView(_ view: CaptureView, context: Context) {
        view.onCombo = { captured in
            if let captured { combo = captured }
            isRecording = false
        }
        view.isRecording = isRecording
        if isRecording { view.window?.makeFirstResponder(view) }
    }
}

final class CaptureView: NSView {
    var isRecording = false
    var onCombo: (Combo?) -> Void = { _ in }

    override var acceptsFirstResponder: Bool { true }

    // Command combos arrive here before keyDown, so this is what lets Command+V and Command+C be captured.
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard isRecording else { return false }
        handle(event)
        return true
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else { return super.keyDown(with: event) }
        handle(event)
    }

    private func handle(_ event: NSEvent) {
        let modifiers = Combo.modifiers(of: event)
        if event.keyCode == 53 && modifiers.isEmpty { return onCombo(nil) }   // Escape cancels
        guard !modifiers.isEmpty, let combo = Combo(event: event) else { return }   // a modifier is required
        onCombo(combo)
    }
}
