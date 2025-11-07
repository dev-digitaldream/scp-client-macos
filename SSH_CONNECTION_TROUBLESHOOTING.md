# Dépannage des connexions SSH

## 🎯 Problème résolu

L'application utilise maintenant **SSH CLI natif** au lieu du bridge C++, ce qui résout les problèmes de connexion par clé SSH !

## 🔧 Nouvelle implémentation

### Avant (problématique)
- Utilisait un bridge C++ compliqué
- Problèmes avec la gestion des clés SSH
- Erreurs "ssh_askpass" et permissions

### Après (solution)
- Utilise **SSH CLI natif** comme dans le terminal
- **Gestion automatique** des clés avec SSHKeyManager
- **Messages d'erreur clairs** et utiles

## 🚀 Utilisation

### Mode clé SSH (recommandé)

1. **Configurez votre connexion** en mode "Clé SSH"
2. **Spécifiez le chemin** de votre clé privée (`~/.ssh/id_rsa` par défaut)
3. **Connectez-vous** - l'application gère automatiquement les clés !

### Mode mot de passe

1. **Configurez votre connexion** en mode "Password"
2. **Assurez-vous que sshpass est installé** :
   ```bash
   brew install hudochenkov/sshpass/sshpass
   ```
3. **Connectez-vous** - l'application demande le mot de passe automatiquement

## 📋 Messages d'erreur améliorés

### "Permission denied"
**Cause** : Clé SSH non valide ou non autorisée sur le serveur
**Solution** : 
- Vérifiez que votre clé est autorisée : `ssh-copy-id user@server`
- Ou passez en mode mot de passe

### "Fichier de clé introuvable"
**Cause** : Chemin de la clé SSH incorrect
**Solution** :
- Vérifiez le chemin : `ls -la ~/.ssh/id_rsa*`
- Utilisez le chemin complet : `/Users/votrenom/.ssh/id_rsa`

### "sshpass n'est pas installé"
**Cause** : sshpass requis pour le mode mot de passe
**Solution** :
```bash
brew install hudochenkov/sshpass/sshpass
```

## 🔧 Vérification manuelle

### Tester votre clé SSH
```bash
# Test manuel de votre clé
ssh -i ~/.ssh/id_rsa user@server "echo 'SSH key works'"

# Si ça fonctionne, l'app devrait fonctionner aussi !
```

### Tester votre mot de passe
```bash
# Test manuel avec sshpass
sshpass -p 'votremotdepasse' ssh user@server "echo 'Password works'"

# Si ça fonctionne, l'app devrait fonctionner aussi !
```

## 🎯 Scénarios courants

### Scénario 1 : Clé SSH non configurée
```
Problème : "Permission denied"
Solution : Configurez votre clé sur le serveur
Commande : ssh-copy-id user@server
```

### Scénario 2 : Serveur avec clé changeante
```
Problème : "Host key verification failed"
Solution : L'application gère automatiquement !
Action : Aucune intervention requise
```

### Scénario 3 : Préférence pour mot de passe
```
Problème : "Je préfère utiliser un mot de passe"
Solution : Passez en mode password + installez sshpass
Action : Changez le type d'authentification
```

## 🔍 Debugging avancé

### Logs détaillés
L'application affiche maintenant des logs détaillés dans la console :
- `🔑 Tentative de connexion avec clé SSH`
- `🔐 Tentative de connexion avec mot de passe`
- `✅ Connexion SSH établie`
- `❌ Échec de la connexion SSH`

### Réinitialiser les clés SSH
Si vous avez des problèmes avec les clés :
```swift
// Dans la console de l'app (future fonctionnalité)
try connectionService.resetSSHKeys()
```

## 💡 Astuces

### Clé SSH la plus simple
```bash
# Générer une clé si vous n'en avez pas
ssh-keygen -t rsa -b 4096

# Copier sur le serveur
ssh-copy-id user@server

# Utiliser dans l'app
Chemin: ~/.ssh/id_rsa
```

### Mot de passe avec sshpass
```bash
# Installer sshpass
brew install hudochenkov/sshpass/sshpass

# Configurer la connexion en mode "Password"
# L'application demandera le mot de passe automatiquement
```

---

## 🎉 Résultat final

**Les connexions SSH fonctionnent maintenant parfaitement :**

- ✅ **Mode clé SSH** - Utilise SSH CLI natif avec gestion automatique des clés
- ✅ **Mode mot de passe** - Utilise sshpass avec boîte de dialogue intégrée
- ✅ **Gestion automatique** des clés known_hosts
- ✅ **Messages d'erreur clairs** pour faciliter le dépannage
- ✅ **Compatible** avec tous les serveurs SSH

*Plus besoin de passer en mode password par défaut - le mode clé SSH fonctionne maintenant !*
