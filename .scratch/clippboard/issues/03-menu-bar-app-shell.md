# 03: Menu bar app shell

**What to build:** a build script produces a real Clippboard `.app` from a Swift Package. Launching it shows an icon in the menu bar with no Dock icon. Clicking the icon opens a small popover just below it, with a Quit option. The popover uses `ConcentricRectangle` for matching corners and targets macOS 26.

**Blocked by:** None (can start immediately).

**Status:** done

- [ ] The build script produces a launchable `.app`
- [ ] The menu bar icon appears and there is no Dock icon
- [ ] Clicking the icon opens a popover directly below it
- [ ] Quit closes the app
- [ ] The popover's nested rounded shapes have matching corners
