#!/bin/bash
# Script pour pusher vers GitHub
# Usage: ./PUSH_TO_GITHUB.sh <votre-username> <nom-du-repo>

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: ./PUSH_TO_GITHUB.sh <username> <repo-name>"
    echo "Exemple: ./PUSH_TO_GITHUB.sh johndoe scp-client-macos"
    exit 1
fi

USERNAME=$1
REPO=$2

echo "🚀 Configuration du remote GitHub..."
git remote add origin "https://github.com/$USERNAME/$REPO.git"

echo "📤 Push vers GitHub..."
git branch -M main
git push -u origin main

echo "✅ Done! Votre projet est sur https://github.com/$USERNAME/$REPO"
