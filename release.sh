#!/bin/sh
# Builds a signed, notarized dist/Paste-<version>.dmg that anyone can download and open.
#
# One-time setup (needs the paid Apple Developer Program):
#   1. Install a "Developer ID Application" certificate in your login Keychain.
#   2. Store notarization credentials under the profile name below:
#        xcrun notarytool store-credentials paste-notary --apple-id <you@example.com> --team-id <TEAMID>
#      It prompts for an app-specific password from appleid.apple.com. Nothing is written to this repo.
#   3. Sparkle's update-signing key must be in your Keychain (.build/artifacts/sparkle/Sparkle/bin/generate_keys).
#      Back it up with generate_keys -x <file>: without it, installed copies can never be updated.
# To ship a new version, change VERSION first.
set -e
cd "$(dirname "$0")"
PROFILE=${NOTARY_PROFILE:-paste-notary}
VERSION=$(tr -d '[:space:]' < VERSION)

IDENTITY=$(security find-identity -v -p codesigning | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' | head -1)
if [ -z "$IDENTITY" ]; then
    echo "No 'Developer ID Application' certificate in your Keychain. See the setup notes at the top of this script." >&2
    exit 1
fi
if ! xcrun notarytool history --keychain-profile "$PROFILE" >/dev/null 2>&1; then
    echo "No notarization profile '$PROFILE'. See the setup notes at the top of this script." >&2
    exit 1
fi

./test.sh 2>&1 | grep -E "✘|Test run"
SIGN_IDENTITY="$IDENTITY" ./build-app.sh

APP=build/Paste.app
DIST=dist
rm -rf "$DIST" && mkdir -p "$DIST"
codesign --verify --strict --verbose=2 "$APP"
codesign -dv "$APP" 2>&1 | grep -q "flags=0x10000(runtime)" || { echo "Hardened runtime is not on." >&2; exit 1; }

echo "Notarizing the app..."
ditto -c -k --keepParent "$APP" "$DIST/Paste-app.zip"
xcrun notarytool submit "$DIST/Paste-app.zip" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$APP"
rm "$DIST/Paste-app.zip"

DMG="$DIST/Paste-$VERSION.dmg"
STAGE=$(mktemp -d); trap 'rm -rf "$STAGE"' EXIT
cp -R "$APP" "$STAGE/"
ln -s /Applications "$STAGE/Applications"
hdiutil create -volname "Paste" -srcfolder "$STAGE" -ov -format UDZO "$DMG" >/dev/null
codesign --force --timestamp --sign "$IDENTITY" "$DMG"

echo "Notarizing the disk image..."
xcrun notarytool submit "$DMG" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$DMG"

spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG"

# The update feed Sparkle reads. It is signed with the private key that Sparkle's generate_keys put in your Keychain.
.build/artifacts/sparkle/Sparkle/bin/generate_appcast \
    --download-url-prefix "https://github.com/matthewpeters-extended/paste/releases/download/v$VERSION/" "$DIST"
echo "Ready: $DMG and $DIST/appcast.xml"
echo "Publish both with:  gh release create v$VERSION $DMG $DIST/appcast.xml --title \"Paste $VERSION\""
