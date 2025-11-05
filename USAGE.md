# 📖 Guide d'utilisation - SCP Client pour macOS

## 🚀 Démarrage rapide

### 1. Première connexion

1. Lancer l'application
2. Cliquer sur **"Nouvelle connexion"**
3. Remplir le formulaire :
   - **Nom** : Nom de votre choix (ex: "Mon serveur")
   - **Hôte** : Adresse IP ou domaine (ex: `192.168.1.100` ou `server.example.com`)
   - **Port** : 22 (par défaut pour SSH)
   - **Nom d'utilisateur** : Votre username SSH
   - **Authentification** : Mot de passe ou Clé privée
4. Cliquer sur **"Enregistrer"**
5. La connexion apparaît dans la sidebar
6. Cliquer dessus et entrer votre mot de passe/passphrase

## 🔐 Authentification

### Avec mot de passe

Simple et direct :
1. Choisir **"Mot de passe"**
2. Le mot de passe sera demandé à chaque connexion
3. Pas de stockage en clair (sécurité maximale)

### Avec clé privée SSH

Plus sécurisé pour une utilisation fréquente :
1. Choisir **"Clé privée"**
2. Cliquer sur **"Parcourir"** et sélectionner votre clé
   - Généralement dans `~/.ssh/id_rsa` ou `~/.ssh/id_ed25519`
3. Si votre clé a une passphrase, elle sera demandée à la connexion

#### Créer une clé SSH (si vous n'en avez pas)

```bash
# Générer une nouvelle clé Ed25519 (recommandé)
ssh-keygen -t ed25519 -C "votre@email.com"

# Ou RSA (plus compatible)
ssh-keygen -t rsa -b 4096 -C "votre@email.com"

# Copier la clé publique sur le serveur
ssh-copy-id user@server.com
```

## 📁 Navigation

### Explorateur de fichiers

- **Double-clic** sur un dossier pour l'ouvrir
- **Bouton ←** pour remonter d'un niveau
- **Bouton ↻** pour actualiser
- **Chemin** affiché en haut montre où vous êtes

### Barre d'outils

- 📁➕ **Nouveau dossier** : Créer un dossier distant
- ↻ **Actualiser** : Recharger la liste des fichiers
- ⚡ **Déconnecter** : Fermer la session SSH

## ⬆️ Upload de fichiers

### Méthode 1 : Drag & Drop (glisser-déposer)

1. Ouvrir le Finder
2. Sélectionner vos fichiers
3. Les glisser dans la fenêtre de l'application
4. Les fichiers sont uploadés automatiquement

### Méthode 2 : Menu contextuel

1. Clic droit sur un fichier local
2. Choisir **"Uploader vers..."**
3. Sélectionner le dossier de destination

## ⬇️ Download de fichiers

1. **Clic droit** sur le fichier distant
2. Choisir **"Télécharger"**
3. Sélectionner où sauvegarder le fichier
4. Le transfert démarre automatiquement

## 📊 Suivi des transferts

Le panneau en bas de l'écran montre :
- ✅ **Fichiers en cours** de transfert
- 📈 **Progression** en pourcentage
- ⚡ **Vitesse** de transfert (MB/s)
- ⏱️ **Temps restant** estimé
- ✓ **Fichiers complétés**
- ❌ **Erreurs** éventuelles

### États des transferts

- 🕐 **En attente** (gris)
- 🔄 **En cours** (bleu)
- ✅ **Terminé** (vert)
- ❌ **Échoué** (rouge)
- ⊘ **Annulé** (orange)

## 🗂️ Opérations sur les fichiers

### Créer un dossier

1. Cliquer sur le bouton **"📁➕"**
2. Entrer le nom du dossier
3. Appuyer sur **Entrée**

### Supprimer un fichier/dossier

1. **Clic droit** sur l'élément
2. Choisir **"Supprimer"**
3. Confirmer (⚠️ irréversible !)

### Renommer (à venir)

Fonctionnalité en développement.

## ⭐ Gestion des favoris

### Ajouter aux favoris

Les connexions créées sont automatiquement sauvegardées dans la sidebar.

### Modifier une connexion

1. **Clic droit** sur la connexion
2. Choisir **"Modifier"**
3. Mettre à jour les informations

### Supprimer une connexion

1. **Clic droit** sur la connexion
2. Choisir **"Supprimer"**
3. Confirmer

### Historique

La date de **dernier accès** est affichée sous chaque connexion.

## ⌨️ Raccourcis clavier

| Raccourci | Action |
|-----------|--------|
| ⌘N | Nouvelle connexion |
| ⌘R | Actualiser |
| ⌘W | Fermer la fenêtre |
| ⌘Q | Quitter |
| ⌘⇧S | Basculer sidebar |
| Entrée | Ouvrir dossier |
| ⌫ | Remonter d'un niveau |
| Espace | Aperçu rapide |

## 🔒 Sécurité

### Stockage des credentials

- ✅ Mots de passe **jamais stockés** en clair
- ✅ Connexions SSH **chiffrées** (TLS)
- ✅ Vérification des **clés d'hôtes**
- ✅ Support **clés privées** SSH

### Vérification des hôtes

À la première connexion, l'empreinte du serveur est vérifiée.
Si elle change, une alerte sera affichée (protection contre les attaques MITM).

## 🐛 Résolution de problèmes

### "Connection refused"

- Vérifier que le serveur SSH est actif : `systemctl status sshd`
- Vérifier le port (22 par défaut)
- Vérifier le firewall

### "Authentication failed"

- Vérifier le nom d'utilisateur
- Vérifier le mot de passe
- Pour clé SSH : vérifier les permissions (`chmod 600 ~/.ssh/id_rsa`)

### "Permission denied"

- Vérifier les permissions sur le serveur
- Vous n'avez peut-être pas les droits d'écriture

### Transfert lent

- Votre connexion réseau peut être limitée
- Le serveur peut être surchargé
- Essayer de compresser les fichiers avant transfert

## 💡 Astuces

### Transfert de gros fichiers

Pour les fichiers > 1 GB :
1. Compresser avant transfert : `tar -czf archive.tar.gz folder/`
2. Uploader l'archive
3. Décompresser sur le serveur : `tar -xzf archive.tar.gz`

### Upload multiple

Sélectionner plusieurs fichiers dans le Finder et les glisser en une fois.

### Connexion rapide

Les connexions récentes sont triées par date d'utilisation.

---

## 📞 Support

- **Issues** : [GitHub Issues](https://github.com/user/scp-client-macos/issues)
- **Documentation** : Voir [README.md](README.md)
- **SSH Help** : `man ssh` ou `man scp`
