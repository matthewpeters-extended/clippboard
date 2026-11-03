#!/bin/sh
# Builds Clippboard and bundles it as build/Clippboard.app (Command Line Tools only, no Xcode).
set -e
cd "$(dirname "$0")"
VERSION=$(tr -d '[:space:]' < VERSION)
swift build -c release
APP=build/Clippboard.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/Clippboard" "$APP/Contents/MacOS/Clippboard"
# Sparkle (the updater) ships as a framework inside the app. Clippboard isn't sandboxed, so its XPC helpers aren't needed.
mkdir -p "$APP/Contents/Frameworks"
ditto .build/artifacts/sparkle/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework "$APP/Contents/Frameworks/Sparkle.framework"
rm -rf "$APP/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices" "$APP/Contents/Frameworks/Sparkle.framework/XPCServices"
install_name_tool -add_rpath @executable_path/../Frameworks "$APP/Contents/MacOS/Clippboard"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key><string>com.matthew.paste</string>
    <key>CFBundleName</key><string>Clippboard</string>
    <key>CFBundleExecutable</key><string>Clippboard</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>$VERSION</string>
    <key>CFBundleVersion</key><string>$VERSION</string>
    <key>LSMinimumSystemVersion</key><string>26.0</string>
    <key>LSUIElement</key><true/>
    <key>SUFeedURL</key><string>https://github.com/matthewpeters-extended/paste/releases/latest/download/appcast.xml</string>
    <key>SUPublicEDKey</key><string>x84bQ4RZf4xKKVUWdYNJn0P6y6WlcIE06V6gQDnJ3VY=</string>
    <key>SUEnableAutomaticChecks</key><true/>
</dict>
</plist>
PLIST
# Always signed with the hardened runtime, so a local build behaves like a release build.
# SIGN_IDENTITY (set by release.sh) picks a Developer ID; otherwise a stable local identity keeps the
# Accessibility permission across rebuilds (see setup-signing.sh), falling back to ad hoc.
ENTITLEMENTS=
if [ -n "$SIGN_IDENTITY" ]; then
    IDENTITY="$SIGN_IDENTITY"; STAMP=--timestamp
elif security find-identity -p codesigning | grep -q "Clippboard Local Signing"; then
    IDENTITY="Clippboard Local Signing"; STAMP=
else
    echo "Note: no 'Clippboard Local Signing' identity; signing ad hoc. Run ./setup-signing.sh once."
    IDENTITY="-"; STAMP=
fi
# A local identity has no Team ID, so the hardened runtime would refuse to load Sparkle into the app.
# A Developer ID build gives both the same Team ID and needs no exception.
if [ -z "$SIGN_IDENTITY" ]; then
    ENTITLEMENTS=build/local.entitlements
    cat > "$ENTITLEMENTS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>com.apple.security.cs.disable-library-validation</key><true/></dict></plist>
PLIST
fi
sign() { codesign --force --options runtime $STAMP --sign "$IDENTITY" "$@"; }
# Inside out: Sparkle's helpers, then its framework, then the app.
SPARKLE="$APP/Contents/Frameworks/Sparkle.framework/Versions/B"
sign "$SPARKLE/Autoupdate"
sign "$SPARKLE/Updater.app"
sign "$APP/Contents/Frameworks/Sparkle.framework"
if [ -n "$ENTITLEMENTS" ]; then sign --entitlements "$ENTITLEMENTS" "$APP"; else sign "$APP"; fi
echo "Built $APP ($VERSION)"
