# 📦 Installation du client SCP pour macOS

## Prérequis

### 1. Xcode et Command Line Tools

```bash
# Installer Xcode depuis l'App Store, puis :
xcode-select --install
```

### 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Dépendances

```bash
brew install libssh2 cmake pkg-config
```

## 🚀 Build depuis les sources

### Méthode 1 : Script automatique (recommandé)

```bash
cd scp-client-macos
./build.sh
```

Le script va :
- ✅ Vérifier toutes les dépendances
- ✅ Compiler la bibliothèque C++ (libssh2)
- ✅ Compiler l'application Swift
- ✅ Créer l'exécutable

### Méthode 2 : Build manuel

```bash
# 1. Compiler la partie C++
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . --config Release
cd ..

# 2. Compiler l'application Swift
swift build -c release
```

### Méthode 3 : Xcode

```bash
# Générer le projet Xcode
swift package generate-xcodeproj

# Ouvrir dans Xcode
open SCPClient.xcodeproj
```

Puis dans Xcode :
1. Sélectionner la target `SCPClient`
2. Product → Build (⌘B)
3. Product → Run (⌘R)

## 📱 Créer une application .app

```bash
# Build l'application
./build.sh

# Créer le bundle .app
./package-app.sh

# Lancer l'app
open build/SCPClient.app
```

## 📀 Créer un DMG

```bash
# Après avoir créé le .app
hdiutil create -volname "SCP Client" \
    -srcfolder "build/SCPClient.app" \
    -ov -format UDZO \
    "build/SCPClient.dmg"
```

## 🔧 Résolution de problèmes

### Erreur : "libssh2 not found"

```bash
# Installer libssh2
brew install libssh2

# Vérifier l'installation
pkg-config --modversion libssh2
```

### Erreur : "cmake not found"

```bash
brew install cmake
```

### Erreur de signature sur Apple Silicon

```bash
# Signer l'application manuellement
codesign --force --deep --sign - build/SCPClient.app
```

### L'app ne se lance pas

```bash
# Vérifier les permissions
chmod +x .build/release/SCPClient

# Lancer en ligne de commande pour voir les erreurs
.build/release/SCPClient
```

## 🎯 Lancer l'application

### Depuis le terminal

```bash
.build/release/SCPClient
```

### Depuis le .app

```bash
open build/SCPClient.app
```

## 🗑️ Désinstallation

```bash
# Supprimer l'application
rm -rf build/SCPClient.app

# Supprimer les builds
rm -rf .build build

# (Optionnel) Désinstaller les dépendances
brew uninstall libssh2
```

## 📊 Configuration système minimale

- **OS** : macOS 13.0 (Ventura) ou supérieur
- **Architecture** : Intel x86_64 ou Apple Silicon (ARM64)
- **RAM** : 2 GB minimum
- **Disque** : 50 MB pour l'application

## 🔐 Permissions

L'application peut demander les permissions suivantes :
- **Fichiers** : Pour lire/écrire des fichiers locaux
- **Réseau** : Pour se connecter aux serveurs SSH
- **Keychain** : Pour stocker les mots de passe (optionnel)

---

Pour toute question, consultez le [README.md](README.md)
