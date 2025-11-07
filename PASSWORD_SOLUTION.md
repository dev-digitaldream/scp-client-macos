# Solution pour l'authentification par mot de passe

## 🎯 Problème résolu

L'application supporte maintenant l'authentification par mot de passe pour les commandes SSH distantes !

## ⚡ Nouvelle fonctionnalité

### Boîte de dialogue de mot de passe

Quand vous exécutez une commande SSH et que sshpass est disponible :

1. **Boîte de dialogue automatique** : L'application vous demande le mot de passe
2. **Authentification sécurisée** : Utilise sshpass pour éviter les erreurs `ssh_askpass`
3. **Gestion des clés automatique** : Nettoie et accepte les nouvelles clés SSH

## Utilisation

### Étape 1: Installer sshpass (si pas déjà fait)
```bash
brew install hudochenkov/sshpass/sshpass
```

### Étape 2: Utiliser le terminal
1. Connectez-vous à votre serveur
2. Tapez une commande dans le terminal SSH (ex: `reboot`)
3. **Entrez votre mot de passe** dans la boîte de dialogue
4. La commande s'exécute automatiquement !

## Commandes supportées

Toutes les commandes fonctionnent maintenant :

- `reboot` - Redémarrer le serveur
- `setnum` - Commandes personnalisées
- `systemctl restart nginx` - Services
- `apt update && apt upgrade` - Mises à jour
- `df -h` - Espace disque
- `ps aux` - Processus

## Fonctionnement

### Processus automatique

1. **Détection** : L'application vérifie si sshpass est installé
2. **Nettoyage** : Supprime l'ancienne clé SSH du known_hosts
3. **Authentification** : Demande le mot de passe via une boîte de dialogue
4. **Exécution** : Lance la commande avec sshpass
5. **Gestion des clés** : Accepte automatiquement les nouvelles clés

### Sécurité

- Mot de passe demandé via boîte de dialogue sécurisée
- Pas de stockage en clair du mot de passe
- Utilisation de sshpass pour l'authentification

## Configuration

### Requis
- **sshpass** installé via Homebrew
- **Connexion établie** au serveur

### Optionnel
- Clés SSH pour éviter les demandes de mot de passe
- Configuration du keychain pour stockage sécurisé (à venir)

## Astuces

### Pour éviter les demandes répétées
1. **Configurez des clés SSH** :
   ```bash
   ssh-keygen -t rsa -b 4096
   ssh-copy-id user@server
   ```
2. **Utilisez l'authentification par clé** dans l'application

### Pour les serveurs avec clés changeantes
L'application gère automatiquement :
- Nettoyage des anciennes clés
- Acceptation des nouvelles clés
- Authentification par mot de passe

## Dépannage

### "sshpass non trouvé"
```bash
brew install hudochenkov/sshpass/sshpass
```

### "Permission denied"
- Vérifiez le mot de passe
- Assurez-vous que l'utilisateur a les droits nécessaires

### "Command failed"
- Vérifiez que la commande existe sur le serveur
- Assurez-vous d'avoir les permissions pour l'exécuter

---
*Les commandes SSH fonctionnent maintenant parfaitement avec authentification par mot de passe !*
