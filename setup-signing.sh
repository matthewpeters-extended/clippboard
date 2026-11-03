#!/bin/sh
# One-time: creates a self-signed "Clippboard Local Signing" code-signing certificate in your login Keychain,
# so rebuilds keep the same signature and macOS keeps the Accessibility permission you granted.
# Local use only; it is not a trusted or distributable identity.
set -e
NAME="Clippboard Local Signing"
if security find-identity -p codesigning | grep -q "$NAME"; then echo "$NAME already exists."; exit 0; fi
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
cat > "$TMP/cert.cnf" <<CNF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no
[dn]
CN = $NAME
[ext]
keyUsage = critical, digitalSignature
extendedKeyUsage = critical, codeSigning
basicConstraints = critical, CA:false
CNF
openssl req -x509 -newkey rsa:2048 -nodes -keyout "$TMP/key.pem" -out "$TMP/cert.pem" -days 3650 -config "$TMP/cert.cnf"
openssl pkcs12 -export -inkey "$TMP/key.pem" -in "$TMP/cert.pem" -out "$TMP/paste.p12" -passout pass:paste -legacy
security import "$TMP/paste.p12" -k ~/Library/Keychains/login.keychain-db -P paste -T /usr/bin/codesign
security find-identity -p codesigning | grep "$NAME"
echo "Done. Now run ./build-app.sh"
