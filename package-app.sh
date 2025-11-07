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
    <key>CFBundleIconFile</key>
    <string>AppIcon.icns</string>
</dict>
</plist>
EOF

# Copier les ressources si elles existent
if [ -d "SCPClient/Resources" ] && [ "$(ls -A SCPClient/Resources 2>/dev/null)" ]; then
    cp -R SCPClient/Resources/* "${RESOURCES_DIR}/"
fi

# Créer l'icône .icns à partir des PNG
echo "🎨 Création de l'icône .icns..."

# Essayer d'utiliser l'icône personnalisée d'abord
if [ -f "/Users/mohammed/scp-client-macos/SCPClient/icon/scp.icon/Assets/scp.png" ]; then
    echo "📋 Utilisation de l'icône personnalisée scp.png..."
    
    # Créer un iconset temporaire
    ICONSET_DIR="${RESOURCES_DIR}/AppIcon.iconset"
    mkdir -p "${ICONSET_DIR}"
    
    # Utiliser sips pour créer toutes les tailles nécessaires depuis l'icône personnalisée transparente
    sips -z 16 16 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_16x16.png"
    sips -z 32 32 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_16x16@2x.png"
    sips -z 32 32 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_32x32.png"
    sips -z 64 64 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_32x32@2x.png"
    sips -z 128 128 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_128x128.png"
    sips -z 256 256 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_128x128@2x.png"
    sips -z 256 256 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_256x256.png"
    sips -z 512 512 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_256x256@2x.png"
    sips -z 512 512 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_512x512.png"
    sips -z 1024 1024 "SCPClient/icon/scp-transparent.png" --out "${ICONSET_DIR}/icon_512x512@2x.png"
    
    # Créer le fichier .icns avec iconutil
    iconutil -c icns "${ICONSET_DIR}" -o "${RESOURCES_DIR}/AppIcon.icns"
    
    # Nettoyer le dossier iconset temporaire
    rm -rf "${ICONSET_DIR}"
    
    echo "✅ Icône personnalisée .icns créée"
    
# Sinon, utiliser les icônes par défaut
elif [ -d "SCPClient/Assets.xcassets/AppIcon.appiconset" ]; then
    echo "📋 Utilisation des icônes par défaut..."
    
    ICONSET_DIR="${RESOURCES_DIR}/AppIcon.iconset"
    mkdir -p "${ICONSET_DIR}"

    # Copier les icônes générées dans l'iconset
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_16x16.png" "${ICONSET_DIR}/icon_16x16.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png" "${ICONSET_DIR}/icon_16x16@2x.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_32x32.png" "${ICONSET_DIR}/icon_32x32.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png" "${ICONSET_DIR}/icon_32x32@2x.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" "${ICONSET_DIR}/icon_128x128.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" "${ICONSET_DIR}/icon_128x128@2x.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" "${ICONSET_DIR}/icon_256x256.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png" "${ICONSET_DIR}/icon_256x256@2x.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" "${ICONSET_DIR}/icon_512x512.png"
    cp "SCPClient/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png" "${ICONSET_DIR}/icon_512x512@2x.png"
    
    # Créer le fichier .icns avec iconutil
    iconutil -c icns "${ICONSET_DIR}" -o "${RESOURCES_DIR}/AppIcon.icns"
    
    # Nettoyer le dossier iconset temporaire
    rm -rf "${ICONSET_DIR}"
    
    echo "✅ Icône par défaut .icns créée"
else
    echo "⚠️  Aucune icône trouvée, utilisation de l'icône par défaut du système"
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
