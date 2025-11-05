#!/bin/bash
# Script de build pour le client SCP macOS

set -e

echo "🚀 Build du client SCP pour macOS"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier que nous sommes sur macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ Ce script doit être exécuté sur macOS${NC}"
    exit 1
fi

# Vérifier Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${RED}❌ Homebrew n'est pas installé${NC}"
    echo "Installez Homebrew : /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Vérifier/installer libssh2
echo -e "${BLUE}📦 Vérification de libssh2...${NC}"
if ! brew list libssh2 &> /dev/null; then
    echo "Installation de libssh2..."
    brew install libssh2
else
    echo -e "${GREEN}✓ libssh2 déjà installé${NC}"
fi

# Vérifier/installer cmake
echo -e "${BLUE}📦 Vérification de cmake...${NC}"
if ! command -v cmake &> /dev/null; then
    echo "Installation de cmake..."
    brew install cmake
else
    echo -e "${GREEN}✓ cmake déjà installé${NC}"
fi

# Vérifier Swift
echo -e "${BLUE}📦 Vérification de Swift...${NC}"
if ! command -v swift &> /dev/null; then
    echo -e "${RED}❌ Swift n'est pas installé. Installez Xcode depuis l'App Store.${NC}"
    exit 1
else
    SWIFT_VERSION=$(swift --version | head -n 1)
    echo -e "${GREEN}✓ ${SWIFT_VERSION}${NC}"
fi

echo ""
echo -e "${BLUE}🔨 Compilation de la bibliothèque C++...${NC}"

# Créer le dossier build
mkdir -p build
cd build

# Configurer CMake
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=13.0

# Compiler
cmake --build . --config Release -j$(sysctl -n hw.ncpu)

echo -e "${GREEN}✓ Bibliothèque C++ compilée${NC}"
echo ""

cd ..

# Build Swift
echo -e "${BLUE}🔨 Compilation de l'application Swift...${NC}"
swift build -c release

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build réussi !${NC}"
    echo ""
    echo "L'exécutable se trouve dans : .build/release/SCPClient"
    echo ""
    echo "Pour lancer l'application :"
    echo "  .build/release/SCPClient"
    echo ""
    echo "Pour créer un .app macOS :"
    echo "  ./package-app.sh"
else
    echo -e "${RED}❌ Échec du build${NC}"
    exit 1
fi
