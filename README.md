# Clippboard

A macOS menu bar app that types your saved text when you press a key combination, in any app. Everything is stored in one local file. The only network use is an optional daily check of GitHub for a newer version. See `CONTEXT.md` for the vocabulary (Binding, Combo, Text, Pause) and `.scratch/clippboard/spec.md` for the spec.

## Install

Download `Clippboard-<version>.dmg` from the [latest release](https://github.com/matthewpeters-extended/paste/releases/latest), open it and drag Clippboard to Applications. Clippboard then updates itself. The Welcome window walks you through the Accessibility permission and Launch at login.

## Website

The landing site is plain HTML in `docs/` (no build step). Live at <https://matthewpeters-extended.github.io/paste/> once GitHub Pages is on: repo **Settings → Pages → Build and deployment → Deploy from a branch → `main` / `/docs`**. Download buttons point at the latest GitHub release.

## Build from source

Needs macOS 26 and the Swift toolchain (Command Line Tools are enough).

```sh
git clone https://github.com/matthewpeters-extended/paste.git && cd paste
./setup-signing.sh               # once: a local signing certificate, so the Accessibility permission survives rebuilds
./build-app.sh                   # builds build/Clippboard.app
cp -R build/Clippboard.app /Applications/
open /Applications/Clippboard.app
```

macOS may ask whether `codesign` can use the signing key. Choose **Always Allow**.

On first launch a **Welcome** window opens and walks you through setup:

1. **Allow Accessibility.** This is the only permission Clippboard needs.
2. **Choose whether Clippboard starts at login.**
3. **Add your first Binding** from the menu bar icon.

## Permissions

| Permission | Needed? | Why |
|---|---|---|
| Accessibility (System Settings → Privacy & Security → Accessibility) | Yes | Lets Clippboard notice your key combinations in other apps and type the text for you. |
| Login item | Optional | Only if you choose to launch at login. macOS may show a one-time "Clippboard can run in the background" notice. |
| Input Monitoring, Screen Recording | No | Clippboard doesn't use them. It never touches your clipboard. |
| Network | Only for updates | Clippboard asks GitHub if a newer version exists (turn it off in Settings → General). It sends no Bindings or personal data. |

If you rebuild without the signing certificate, macOS may treat each build as a new app. If the Accessibility notice stays after you allowed Clippboard, remove Clippboard from the list with **−**, reopen the app and allow it again. Clippboard doesn't type into password fields.

## Release

`VERSION` holds the version number. To ship, change it and run `./release.sh`. It needs a Developer ID certificate and a notarization profile (setup notes are at the top of the script). It tests, builds, signs with the hardened runtime, notarizes, makes `dist/Clippboard-<version>.dmg` and the `dist/appcast.xml` update feed. Upload both to a GitHub release as the script prints. Keep a backup of the Sparkle signing key: `.build/artifacts/sparkle/Sparkle/bin/generate_keys -x paste-sparkle-key`.

## Test

```sh
./test.sh
```

`./test.sh` wraps `swift test` with the flags the Command Line Tools need to find Swift Testing. Tests cover `ClippboardCore`, which has no macOS code. The menu bar, key recorder, typing and permission screens are checked by hand.

## Layout

- `Sources/ClippboardCore`: Bindings, Pause, duplicate and system-Combo checks, storage.
- `Sources/Clippboard`: the app (popover, Settings window, key listener, typer).

Bindings are saved in `~/Library/Application Support/Clippboard/bindings.json`.
