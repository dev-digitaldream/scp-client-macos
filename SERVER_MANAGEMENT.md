# Guide de gestion des serveurs

## 🎯 Nouvelles fonctionnalités

L'application permet maintenant de **modifier** et **supprimer** les serveurs enregistrés !

## 📝 Modifier un serveur

### Méthode 1: Clic droit

1. Faites un clic droit sur le serveur dans la liste
2. Sélectionnez "Modifier" dans le menu contextuel
3. Modifiez les informations nécessaires (nom, hôte, port, etc.)
4. Cliquez sur "Mettre à jour" pour sauvegarder

### Méthode 2: Menu contextuel

- Clic droit sur le serveur → "Modifier"

## 🗑️ Supprimer un serveur

### Méthode 1: Clic droit

1. Faites un clic droit sur le serveur à supprimer
2. Sélectionnez "Supprimer" dans le menu contextuel
3. Confirmez la suppression

### Méthode 2: Menu contextuel

- Clic droit sur le serveur → "Supprimer"

## ⚠️ Important

- **Suppression permanente** : Quand vous supprimez un serveur, il est retiré définitivement de la liste
- **Pas d'impact sur les connexions actives** : Supprimer un serveur ne déconnecte pas une session en cours
- **Sauvegarde automatique** : Toutes les modifications sont sauvegardées automatiquement

## 🔧 Champs modifiables

Lors de l'édition d'un serveur, vous pouvez modifier :

- **Nom** : Le nom d'affichage du serveur
- **Hôte** : Adresse IP ou nom de domaine
- **Port** : Port SSH (par défaut 22)
- **Nom d'utilisateur** : Login SSH
- **Protocole** : SCP ou SFTP
- **Type d'authentification** : Mot de passe ou clé privée
- **Chemin de la clé privée** : Si vous utilisez l'auth par clé

## 💡 Astuces

### Organiser vos serveurs

- Utilisez des noms clairs (ex: "Production Web", "Dev Database", "Backup Server")
- Ajoutez des détails dans le nom pour facilement identifier l'environnement

### Sécurité

- Changez régulièrement vos clés SSH
- Mettez à jour les informations de connexion quand nécessaire
- Supprimez les anciens serveurs qui ne sont plus utilisés

### Dépannage

- Si une connexion ne fonctionne plus après modification, vérifiez :
  - L'adresse IP ou le nom de domaine
  - Le port (22 par défaut)
  - Les identifiants
  - Le chemin de la clé privée (si applicable)

---

*Le gestionnaire de serveurs est maintenant entièrement fonctionnel !*
