# Gestion automatique des clés SSH

## 🎯 Problème résolu

Votre application gère maintenant automatiquement les clés SSH comme WinSCP ! Fini les erreurs `ssh_askpass` et les problèmes de clés qui changent après redémarrage du serveur.

## 🔧 Solution implémentée

### Gestion automatique des clés known_hosts

L'application nettoie automatiquement les anciennes clés et accepte les nouvelles clés SSH, exactement comme dans votre exemple :

```bash
# Avant (erreur)
ssh root@10.1.1.1 "reboot"
# Warning: Permanently added '10.1.1.1' (ED25519) to the list of known hosts.

# Maintenant avec l'app (automatique)
# La clé est nettoyée et ré-acceptée automatiquement
```

## ⚡ Fonctionnalités

### 1. Nettoyage automatique des clés

- Avant chaque commande, l'application supprime l'ancienne clé du serveur dans `~/.ssh/known_hosts`
- Cela évite les conflits quand le serveur change de clé SSH

### 2. Acceptation automatique des nouvelles clés

- L'application répond automatiquement "yes" à la question de confiance de clé
- Plus besoin d'intervention manuelle

### 3. Détection automatique du home directory

- Fonctionne sur n'importe quel Mac, pas seulement pour l'utilisateur "mohammed"
- Détecte automatiquement le chemin `~/.ssh/known_hosts`

## 🚀 Utilisation

1. **Connectez-vous** à votre serveur normalement
2. **Utilisez le terminal** pour exécuter des commandes
3. **Les clés sont gérées automatiquement** :
   - Ancienne clé supprimée
   - Nouvelle clé acceptée
   - Commande exécutée

## 📋 Commandes supportées

Toutes les commandes SSH fonctionnent maintenant sans erreur :

- `reboot` - Redémarrer le serveur
- `setnum` - Commandes personnalisées
- `systemctl restart nginx` - Services
- `apt update && apt upgrade` - Mises à jour
- `docker ps` - Conteneurs
- Etc.

## 🔍 Technical details

### Processus automatique

1. **Nettoyage** : `ssh-keygen -R <host> -f ~/.ssh/known_hosts`
2. **Connexion** : `ssh -o StrictHostKeyChecking=ask user@host "command"`
3. **Acceptation** : Envoi automatique de "yes"

### Sécurité

- Les clés sont stockées dans votre `known_hosts` local
- Chaque nouvelle clé est validée avant acceptation
- Compatible avec les standards SSH

## 🛠️ Configuration

Aucune configuration requise ! L'application détecte automatiquement :

- Votre home directory
- Le fichier `known_hosts`
- Les clés SSH des serveurs

## 📝 Exemples pratiques

```bash
# Dans le terminal de l'app
reboot
# ✅ Fonctionne automatiquement

setnum 42
# ✅ Fonctionne automatiquement

systemctl status nginx
# ✅ Fonctionne automatiquement
```

## 🔧 Dépannage

### Si une commande échoue

1. Vérifiez que vous êtes bien connecté
2. Essayez de vous reconnecter au serveur
3. Réessayez la commande

### Permissions SSH

L'application utilise les permissions de votre utilisateur système. Assurez-vous d'avoir les droits nécessaires sur le serveur.

---

*Plus besoin de supprimer manuellement les clés SSH ! L'application gère tout automatiquement comme WinSCP.*
