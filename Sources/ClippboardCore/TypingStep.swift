/// One action needed to type a Binding's Text: some characters, or a press of Return.
/// Line breaks become Return presses because many apps ignore a line-break character typed as text.
public enum TypingStep: Equatable, Sendable {
    case text(String)
    case newline

    public static func steps(for text: String) -> [TypingStep] {
        var steps: [TypingStep] = []
        var current = ""
        for character in text {
            // Swift treats "\r\n" as a single Character, so it counts as one line break.
            if character.isNewline {
                if !current.isEmpty { steps.append(.text(current)); current = "" }
                steps.append(.newline)
            } else {
                current.append(character)
            }
        }
        if !current.isEmpty { steps.append(.text(current)) }
        return steps
    }
}
