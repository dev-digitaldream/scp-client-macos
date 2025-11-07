# Guide d'utilisation des commandes SSH distantes

## 🚀 Fonctionnalités

Le client SCP intègre maintenant un terminal SSH qui permet d'exécuter des commandes directement sur la machine distante, similaire à WinSCP.

## ⚠️ Configuration requise

### Pour les connexions par mot de passe

Les commandes distantes nécessitent une configuration supplémentaire :

#### Option 1: Installer sshpass (recommandé)

```bash
brew install hudochenkov/sshpass/sshpass
```

#### Option 2: Utiliser des clés SSH (plus sécurisé)

1. Générer une clé SSH :

```bash
ssh-keygen -t rsa -b 4096 -C "votre_email@example.com"
```

2. Copier la clé sur le serveur distant :

```bash
ssh-copy-id utilisateur@serveur
```

3. Dans l'application, utilisez la connexion par clé SSH au lieu du mot de passe

## 📋 Commandes supportées

Vous pouvez exécuter la plupart des commandes Linux/Unix :

### Commandes système

- `reboot` - Redémarrer la machine
- `shutdown -h now` - Éteindre la machine
- `uptime` - Temps de fonctionnement
- `top` - Processus actifs
- `ps aux` - Liste des processus

### Gestion de fichiers

- `ls -la` - Lister les fichiers détaillés
- `pwd` - Répertoire courant
- `cd /chemin` - Changer de répertoire
- `mkdir dossier` - Créer un dossier
- `rm fichier` - Supprimer un fichier
- `chmod 755 fichier` - Changer les permissions

### Archives

- `unzip fichier.zip` - Décompresser un ZIP
- `tar -xzf archive.tar.gz` - Décompresser un TAR.GZ
- `tar -xjf archive.tar.bz2` - Décompresser un TAR.BZ2

### Réseau

- `ping google.com` - Tester la connectivité
- `netstat -tuln` - Ports ouverts
- `ifconfig` - Configuration réseau

## 🖥️ Utilisation dans l'application

1. Connectez-vous à votre serveur (préférez la connexion par clé SSH)
2. Cliquez sur l'onglet "Terminal SSH"
3. Tapez votre commande dans le champ de saisie
4. Appuyez sur Entrée ou cliquez sur le bouton d'exécution
5. La sortie s'affiche dans la zone de résultats

## 🔧 Dépannage

### Erreur "Permission denied"

- Configurez une authentification par clé SSH
- Ou installez sshpass et reconnectez-vous

### Erreur "ssh_askpass"

- L'application essaie d'ouvrir une boîte de dialogue pour le mot de passe
- Utilisez une clé SSH ou sshpass

### Commande ne s'exécute pas

- Vérifiez que vous avez les permissions nécessaires
- Certaines commandes nécessitent les privilèges sudo

## 📝 Exemples pratiques

```bash
# Redémarrer un service web
sudo systemctl restart nginx

# Vérifier l'espace disque
df -h

# Lister les processus MySQL
ps aux | grep mysql

# Décompresser une archive
unzip backup.zip

# Changer les permissions d'un dossier
chmod -R 755 /var/www/html

# Vérifier les logs
tail -f /var/log/syslog
```

## 🛡️ Sécurité

- Préférez toujours l'authentification par clé SSH au mot de passe
- Soyez prudent avec les commandes système (reboot, shutdown)
- Utilisez sudo uniquement si nécessaire

---

*Pour plus d'aide, consultez la documentation complète du projet.*
