#!/bin/bash
# Script pour créer un .app bundle macOS

set -e

APP_NAME="SCPClient"
BUILD_DIR=".build/release"
APP_DIR="build/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📦 Création du bundle macOS..."

# Nettoyer l'ancien build
rm -rf "${APP_DIR}"

# Créer la structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copier l'exécutable
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

# Créer Info.plist
cat > "${CONTENTS_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.scpclient.app</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024. All rights reserved.</string>
</dict>
</plist>
EOF

# Copier les ressources si elles existent
if [ -d "SCPClient/Resources" ]; then
    cp -R SCPClient/Resources/* "${RESOURCES_DIR}/"
fi

# Rendre l'exécutable executable
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "✅ Bundle créé : ${APP_DIR}"
echo ""
echo "Pour lancer l'application :"
echo "  open ${APP_DIR}"
echo ""
echo "Pour créer un DMG :"
echo "  hdiutil create -volname \"${APP_NAME}\" -srcfolder \"${APP_DIR}\" -ov -format UDZO \"build/${APP_NAME}.dmg\""
