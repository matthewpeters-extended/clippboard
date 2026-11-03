# Clippboard: spec

Status: implemented

## Problem Statement

I type the same pieces of text over and over: a postal code, a LinkedIn URL, an email address. Typing or hunting for them each time is slow. I want to attach a piece of text to a key combination of my choosing, so that pressing the combination types the text for me in whatever app I'm using.

## Solution

Clippboard is a macOS menu bar app. Clicking its icon opens a small popover just below the icon. In the popover I manage my **Bindings**: each links a **Combo** to some plain **Text**. When I press a Combo in any app, Clippboard types the Text. A **Pause** switch turns every Binding off at once so my keys behave normally. Everything is stored locally on my Mac and the app never touches the network.

## User Stories

1. As a user, I want a Clippboard icon in the menu bar, so that I can reach it without a Dock icon or window.
2. As a user, I want clicking the icon to open a small popover just below it, so that managing Bindings feels lightweight.
3. As a user, I want to add a Binding with a label, a Combo and some Text, so that I can link a key combination to text I use often.
4. As a user, I want to set a Combo by pressing the keys I want, so that I don't have to type it out or make typos.
5. As a user, I want any key combination to be allowed, including Command+V and Command+C, so that I can bind my most common keys.
6. As a user, I want pressing a bound Combo in any app to type its Text, so that I don't have to type it myself.
7. As a user, I want the Text typed directly as characters, so that my real clipboard is left alone.
8. As a user, I want to give each Binding a short label such as "Postal code", so that the list is easy to read.
9. As a user, I want to switch an individual Binding on or off, so that I can keep it without using it.
10. As a user, I want to edit a Binding's label, Combo or Text, so that I can fix or update it.
11. As a user, I want to delete a Binding, so that I can remove ones I no longer need.
12. As a user, I want a duplicate Combo to be rejected with a clear message, so that two Bindings never fight over the same keys.
13. As a user, I want a warning when I pick a Combo the system already uses, so that I know I'm overriding something before I do it.
14. As a user, I want a Pause switch that stops every Binding at once, so that I can get normal copy and paste back instantly.
15. As a user, I want the Pause state to be obvious from the menu bar icon, so that I know whether my keys are being overridden.
16. As a user, I want a Binding that is switched off or Paused to let the key through normally, so that I never lose a key I need.
17. As a user, I want my Bindings to survive quitting and restarting the app, so that I only set them up once.
18. As a user, I want my Bindings kept only in a local file, so that nothing I enter is ever sent over the network.
19. As a user, I want the app to make no network connections at all, so that I can trust it with private text.
20. As a user, I want a first-run screen that explains the macOS permission Clippboard needs and links me to the right System Settings pane, so that setup is not confusing.
21. As a user, I want to see clearly when the permission is missing, so that I understand why Bindings aren't firing.
22. As a user, I want Clippboard to launch at login, so that my Bindings always work.
23. As a user, I want no Dock icon, so that Clippboard stays out of the way.
24. As a user, I want Clippboard not to fire in macOS password fields, so that it can't type into places it shouldn't.
25. As a user, I want a Quit option in the popover, so that I can close the app.
26. As a user, I want the popover to use matching rounded corners at every nesting level, so that it looks native on macOS 26.

## Implementation Decisions

- Clippboard is a native Swift/SwiftUI app using `MenuBarExtra`, targeting macOS 26 so the popover can use `ConcentricRectangle` for matching corners.
- A **core module** has no macOS code in it. It owns the set of Bindings and the Pause state.
  - Given a pressed Combo, it returns the Text to type, or nothing.
  - It rejects duplicate Combos.
  - It flags Combos the system already uses.
  - It loads and saves Bindings through a storage interface, with a file-backed version for the app and an in-memory version for tests.
- Thin macOS edges wrap the core:
  - A keystroke listener that reports pressed Combos and lets the keys through when the core returns nothing.
  - A typer that emits the Text as characters without using the clipboard.
  - The popover UI, including a key recorder field.
  - A permission screen.
  - A launch-at-login switch.
- Bindings are stored in one local file. There is no network access. The file may later move to the Keychain if sensitive text becomes a use case.
- One Combo maps to one Text. Cycling through several Texts is not supported.
- Overriding system Combos such as Command+V and Command+C is allowed, with a warning.
- The app has no Dock icon.
- With only the Command Line Tools installed, the app is built as a Swift Package and bundled as an `.app` by script.

## Testing Decisions

- A good test checks external behavior only: what Text comes out for a given Combo and state, not how the core is built inside.
- The single test seam is the core module.
  - A bound Combo returns its Text.
  - A switched-off Binding returns nothing.
  - While Paused, every Combo returns nothing.
  - A duplicate Combo is rejected.
  - A system-reserved Combo is flagged.
  - Bindings survive a save and reload, using the in-memory store.
- The macOS edges are checked by hand, because they need real permissions and a real keyboard.
- There is no prior art in this repo, since it is new.

## Out of Scope

- Clipboard history.
- Rich text, images and files.
- Cycling several Texts on one Combo.
- Per-app Bindings.
- A global hotkey to open the popover.
- Syncing across devices or any network feature.
- Sharing or distributing the app to others.
- Encrypting the Bindings file.

## Further Notes

- Vocabulary comes from `CONTEXT.md`: Binding, Combo, Text, Pause.
- macOS blocks keystroke interception in secure input fields. That behavior is accepted.
