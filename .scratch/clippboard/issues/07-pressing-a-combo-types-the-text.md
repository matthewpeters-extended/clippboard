# 07: Pressing a Combo types the Text

**What to build:** the keystroke listener and the typer. Pressing a bound Combo in any app types its Text as characters, and the clipboard is left alone. Unbound, switched-off or Paused keys pass through normally. It does not fire in password fields.

**Blocked by:** 02: Core: saving to a local file and system-Combo warning; 06: First-run permission screen.

**Status:** done

- [ ] A bound Combo types its Text in another app
- [ ] The clipboard is unchanged afterward
- [ ] A switched-off Binding lets the key through normally
- [ ] While Paused, every key behaves normally
- [ ] Nothing is typed into a password field
- [ ] A Binding on Command+V and one on Command+C both work
