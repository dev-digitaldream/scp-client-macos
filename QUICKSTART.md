# ⚡ Quick Start - SCP Client pour macOS

Guide de démarrage rapide en 5 minutes !

## 🎯 Installation en 3 commandes

```bash
# 1. Installer les dépendances
brew install libssh2 cmake pkg-config

# 2. Compiler le projet
./build.sh

# 3. Lancer l'application
.build/release/SCPClient
```

C'est tout ! 🎉

## 📋 Checklist pré-installation

Avant de commencer, assurez-vous d'avoir :

- [ ] **macOS 13.0+** (Ventura ou supérieur)
- [ ] **Xcode** installé (App Store)
- [ ] **Homebrew** installé ([brew.sh](https://brew.sh))
- [ ] **Command Line Tools** : `xcode-select --install`

## 🚀 Premier test

Une fois l'application lancée :

### 1. Créer une connexion

```
Nom : Test Server
Hôte : votre-serveur.com (ou 192.168.1.100)
Port : 22
Username : votre-username
Auth : Mot de passe
```

Cliquez **"Enregistrer"**

### 2. Se connecter

1. Cliquez sur la connexion dans la sidebar
2. Entrez votre mot de passe
3. Vous êtes connecté ! 🎊

### 3. Uploader un fichier

**Méthode simple** : Glissez un fichier depuis le Finder vers la fenêtre

**Méthode alternative** :
1. Clic droit sur un fichier distant
2. "Télécharger"
3. Choisissez où sauvegarder

## 📁 Structure du projet créé

```
scp-client-macos/
├── SCPClient/
│   ├── Sources/
│   │   ├── Models/                    # 3 fichiers
│   │   │   ├── Connection.swift       # Modèle connexion
│   │   │   ├── RemoteFile.swift       # Modèle fichiers
│   │   │   └── TransferTask.swift     # Modèle transferts
│   │   ├── Views/                     # 5 fichiers
│   │   │   ├── ContentView.swift      # Vue principale
│   │   │   ├── SidebarView.swift      # Sidebar favoris
│   │   │   ├── FileExplorerView.swift # Explorateur
│   │   │   ├── TransferPanel.swift    # Transferts
│   │   │   └── ConnectionFormView.swift
│   │   ├── Services/                  # 6 fichiers
│   │   │   ├── SCPSession.h/.cpp      # Backend C++
│   │   │   ├── SCPSessionBridge.h/.mm # Bridge Obj-C++
│   │   │   ├── ConnectionService.swift
│   │   │   └── ConnectionManager.swift
│   │   └── SCPClientApp.swift         # Point d'entrée
│   ├── Resources/                     # Assets
│   └── Supporting Files/              # Config
├── CMakeLists.txt                     # Config C++
├── Package.swift                      # Config Swift
├── build.sh                           # Script build
├── package-app.sh                     # Créer .app
├── README.md                          # Doc principale
├── INSTALL.md                         # Guide install
├── USAGE.md                           # Guide utilisation
└── LICENSE                            # MIT

Total : ~2500 lignes de code
```

## 🔧 Commandes utiles

```bash
# Build release
./build.sh

# Build debug (pour développement)
swift build

# Lancer en debug
.build/debug/SCPClient

# Créer un .app
./package-app.sh

# Ouvrir l'app
open build/SCPClient.app

# Créer un DMG
hdiutil create -volname "SCP Client" \
    -srcfolder "build/SCPClient.app" \
    -ov -format UDZO "build/SCPClient.dmg"

# Nettoyer les builds
rm -rf .build build

# Ouvrir dans Xcode
swift package generate-xcodeproj
open SCPClient.xcodeproj
```

## 🐛 Dépannage rapide

### Erreur "libssh2 not found"
```bash
brew install libssh2
```

### Erreur de compilation C++
```bash
brew reinstall cmake pkg-config
rm -rf build
./build.sh
```

### L'app ne se lance pas
```bash
# Vérifier les permissions
chmod +x .build/release/SCPClient

# Lancer en ligne de commande pour voir les erreurs
.build/release/SCPClient
```

### Erreur de connexion SSH
```bash
# Tester SSH manuellement
ssh username@host

# Vérifier que le port 22 est ouvert
nc -zv host 22
```

## 📚 Prochaines étapes

1. **Lire** [USAGE.md](USAGE.md) pour les fonctionnalités avancées
2. **Consulter** [INSTALL.md](INSTALL.md) pour l'installation détaillée
3. **Contribuer** sur GitHub (pull requests bienvenues !)

## 💡 Exemples d'utilisation

### Connexion avec clé SSH

```
Auth : Clé privée
Chemin : /Users/vous/.ssh/id_rsa
Passphrase : (si nécessaire)
```

### Upload multiple

Sélectionner plusieurs fichiers dans le Finder et les glisser en une fois.

### Créer un dossier distant

Cliquer sur **📁+** → Entrer le nom → Entrée

### Suivi des transferts

Le panneau en bas montre :
- Progression en %
- Vitesse (MB/s)
- Temps restant

## ⌨️ Raccourcis indispensables

| Raccourci | Action |
|-----------|--------|
| `⌘N` | Nouvelle connexion |
| `⌘R` | Actualiser la liste |
| `Entrée` | Ouvrir dossier |
| `⌫` | Remonter d'un niveau |
| `⌘W` | Fermer fenêtre |

## 🎓 Ressources

- **SSH** : `man ssh` ou `man scp`
- **libssh2** : [libssh2.org](https://www.libssh2.org)
- **SwiftUI** : [developer.apple.com](https://developer.apple.com/swiftui/)

## ✅ Fonctionnalités principales

- [x] Connexion SSH/SCP sécurisée
- [x] Upload/Download avec drag & drop
- [x] Barre de progression en temps réel
- [x] Gestion des favoris
- [x] Navigation intuitive
- [x] Interface native macOS
- [x] Support clés SSH
- [x] Transferts multiples

## 🆘 Besoin d'aide ?

- 📖 Voir [README.md](README.md) pour la doc complète
- 🐛 Reporter un bug sur GitHub Issues
- 💬 Poser une question sur GitHub Discussions

---

**Prêt à commencer ?** Lancez `./build.sh` ! 🚀
