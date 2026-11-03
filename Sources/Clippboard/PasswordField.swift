import ApplicationServices
import Carbon.HIToolbox

/// Whether key presses are going into a password field, where Clippboard must stay out of the way.
enum PasswordField {
    static var isFocused: Bool {
        if IsSecureEventInputEnabled() { return true }
        let system = AXUIElementCreateSystemWide()
        var focused: CFTypeRef?
        guard AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &focused) == .success,
              let element = focused else { return false }
        var subrole: CFTypeRef?
        AXUIElementCopyAttributeValue(element as! AXUIElement, kAXSubroleAttribute as CFString, &subrole)
        return (subrole as? String) == "AXSecureTextField"
    }
}
