import Foundation
import Testing
import ClippboardCore

@Test func aBoundComboReturnsItsText() throws {
    var bindings = Bindings()
    let combo = Combo(key: "l", modifiers: [.command, .shift])
    try bindings.add(Binding(label: "LinkedIn", combo: combo, text: "https://linkedin.com/in/me"))

    #expect(bindings.text(for: combo) == "https://linkedin.com/in/me")
}

@Test func aSwitchedOffBindingReturnsNothing() throws {
    var bindings = Bindings()
    let combo = Combo(key: "v", modifiers: [.command])
    try bindings.add(Binding(label: "Postal code", combo: combo, text: "M5V 2T6", isEnabled: false))

    #expect(bindings.text(for: combo) == nil)
}

@Test func whilePausedEveryComboReturnsNothing() throws {
    var bindings = Bindings()
    let a = Combo(key: "v", modifiers: [.command])
    let b = Combo(key: "l", modifiers: [.command, .shift])
    try bindings.add(Binding(label: "A", combo: a, text: "one"))
    try bindings.add(Binding(label: "B", combo: b, text: "two"))

    bindings.isPaused = true

    #expect(bindings.text(for: a) == nil)
    #expect(bindings.text(for: b) == nil)

    bindings.isPaused = false

    #expect(bindings.text(for: a) == "one")
}

@Test func aDuplicateComboIsRejected() throws {
    var bindings = Bindings()
    let combo = Combo(key: "v", modifiers: [.command])
    try bindings.add(Binding(label: "First", combo: combo, text: "one"))

    #expect(throws: BindingsError.duplicateCombo) {
        try bindings.add(Binding(label: "Second", combo: combo, text: "two"))
    }
    #expect(bindings.text(for: combo) == "one")
}

@Test func bindingsSurviveASaveAndReload() throws {
    let store = InMemoryBindingStore()
    let combo = Combo(key: "l", modifiers: [.command, .shift])

    var first = try Bindings(store: store)
    let linkedIn = Binding(label: "LinkedIn", combo: combo, text: "https://linkedin.com/in/me", isEnabled: false)
    try first.add(linkedIn)

    let reloaded = try Bindings(store: store)

    #expect(reloaded.all == [linkedIn])
}

@Test func theFileBackedStoreWritesAndReadsOneLocalFile() throws {
    let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: dir) }
    let file = dir.appendingPathComponent("bindings.json")
    let combo = Combo(key: "e", modifiers: [.command, .option])

    var first = try Bindings(store: FileBindingStore(url: file))
    try first.add(Binding(label: "Email", combo: combo, text: "me@example.com"))

    let reloaded = try Bindings(store: FileBindingStore(url: file))

    #expect(reloaded.text(for: combo) == "me@example.com")
    #expect(try FileManager.default.contentsOfDirectory(atPath: dir.path) == ["bindings.json"])
}

@Test func aMissingFileLoadsAsNoBindings() throws {
    let file = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("bindings.json")

    #expect(try Bindings(store: FileBindingStore(url: file)).all.isEmpty)
}

@Test func aSystemReservedComboIsFlaggedButStillAllowed() throws {
    let paste = Combo(key: "v", modifiers: [.command])
    let copy = Combo(key: "c", modifiers: [.command])
    let linkedIn = Combo(key: "l", modifiers: [.command, .shift])

    #expect(paste.isSystemReserved)
    #expect(copy.isSystemReserved)
    #expect(!linkedIn.isSystemReserved)

    var bindings = Bindings()
    try bindings.add(Binding(label: "Postal code", combo: paste, text: "M5V 2T6"))

    #expect(bindings.text(for: paste) == "M5V 2T6")
}

@Test func aComboIsDisplayedWithModifierSymbolsInMacOSOrder() {
    #expect(Combo(key: "l", modifiers: [.shift, .command]).displayString == "⇧⌘L")
    #expect(Combo(key: "v", modifiers: [.command]).displayString == "⌘V")
    #expect(Combo(key: "e", modifiers: [.control, .option, .shift, .command]).displayString == "⌃⌥⇧⌘E")
    #expect(Combo(key: "space", modifiers: [.command]).displayString == "⌘Space")
}

@Test func removingABindingDeletesItAndPersists() throws {
    let store = InMemoryBindingStore()
    var bindings = try Bindings(store: store)
    let keep = Binding(label: "Keep", combo: Combo(key: "k", modifiers: [.command]), text: "keep")
    let drop = Binding(label: "Drop", combo: Combo(key: "d", modifiers: [.command]), text: "drop")
    try bindings.add(keep)
    try bindings.add(drop)

    try bindings.remove(id: drop.id)

    #expect(bindings.text(for: drop.combo) == nil)
    #expect(try Bindings(store: store).all == [keep])
}

@Test func updatingABindingReplacesItAndPersists() throws {
    let store = InMemoryBindingStore()
    var bindings = try Bindings(store: store)
    var postal = Binding(label: "Postal code", combo: Combo(key: "p", modifiers: [.command]), text: "M5V 2T6")
    try bindings.add(postal)

    postal.text = "K1A 0B1"
    postal.combo = Combo(key: "p", modifiers: [.command, .shift])
    postal.isEnabled = false
    try bindings.update(postal)

    #expect(try Bindings(store: store).all == [postal])
}

@Test func updatingToAnotherBindingsComboIsRejected() throws {
    var bindings = Bindings()
    let a = Binding(label: "A", combo: Combo(key: "a", modifiers: [.control]), text: "one")
    var b = Binding(label: "B", combo: Combo(key: "b", modifiers: [.control]), text: "two")
    try bindings.add(a)
    try bindings.add(b)

    b.combo = a.combo

    #expect(throws: BindingsError.duplicateCombo) { try bindings.update(b) }
    #expect(bindings.text(for: Combo(key: "b", modifiers: [.control])) == "two")
}

@Test func aCommonSystemComboSaysWhatItNormallyDoes() {
    #expect(Combo(key: "f", modifiers: [.command]).systemUse == "Find")
    #expect(Combo(key: "v", modifiers: [.command]).systemUse == "Clippboard")
    #expect(Combo(key: "z", modifiers: [.command, .shift]).systemUse == "Redo")
    #expect(Combo(key: "4", modifiers: [.command, .shift]).systemUse == "Take a screenshot")
    #expect(Combo(key: "l", modifiers: [.command, .shift]).systemUse == nil)
    #expect(Combo(key: "f", modifiers: [.command]).isSystemReserved)
}

@Test func textIsSplitIntoTypedTextAndReturnPresses() {
    #expect(TypingStep.steps(for: "M5V 2T6") == [.text("M5V 2T6")])
    #expect(TypingStep.steps(for: "Dear Sam,\nThanks!") == [.text("Dear Sam,"), .newline, .text("Thanks!")])
    #expect(TypingStep.steps(for: "a\r\nb") == [.text("a"), .newline, .text("b")])
    #expect(TypingStep.steps(for: "a\n\nb") == [.text("a"), .newline, .newline, .text("b")])
    #expect(TypingStep.steps(for: "line\n") == [.text("line"), .newline])
    #expect(TypingStep.steps(for: "") == [])
}
