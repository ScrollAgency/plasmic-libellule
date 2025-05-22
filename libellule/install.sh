#!/bin/bash

# 🚨 Arrêter le script en cas d'erreur
set -e

# ✅ Charger les variables d’environnement depuis .env.install
if [ -f .env.install ]; then
  export $(grep -v '^#' .env.install | xargs)
else
  echo "⚠️ Fichier .env.install introuvable. Veuillez en créer un à partir de env.install.model."
  exit 1
fi

# 🧰 Demander si on veut installer Plasmic
read -p "Souhaites-tu installer Plasmic ? (o/n) : " install_plasmic

if [[ "$install_plasmic" =~ ^[oOyY]$ ]]; then
  echo "🧰 Installation de Plasmic..."

  read -p "Indique le nom de ton projet Plasmic : " monapp

  if [ -z "$monapp" ]; then
    echo "❌ Nom du projet invalide. Abandon."
    exit 1
  fi

  echo "📦 Création du projet $monapp avec create-plasmic-app..."
  npx create-plasmic-app "$monapp"

  echo "📂 Copie du contenu de $monapp dans le projet actuel..."
  # Copier tout (y compris les fichiers cachés)
  shopt -s dotglob
  cp -r "$monapp"/* "$monapp"/.[!.]* .

  echo "🧹 Suppression du dossier temporaire $monapp..."
  rm -rf "$monapp"

else
  echo "⏭️ Installation de Plasmic ignorée."
fi

# 🧼 Nettoyage des fichiers potentiellement déjà présents
rm -f tsconfig.json next.config.mjs

# 📥 Téléchargement des fichiers depuis l'API
echo "⬇️ Téléchargement des fichiers depuis $API_URL..."
curl -L -o first-install.ts "$API_URL?file=pages/api/lib-ellule/first-install.ts"
curl -L -o install-log.ts "$API_URL?file=pages/api/lib-ellule/install-log.ts"
curl -L -o libellule.tsx "$API_URL?file=pages/libellule.tsx"
curl -L -o libellule.module.css "$API_URL?file=pages/api/lib-ellule/libellule.module.css"
curl -L -o tsconfig.json "$API_URL?file=tsconfig.json"
curl -L -o next.config.mjs "$API_URL?file=next.config.mjs"
curl -L -o env.modele "$API_URL?file=env.modele"
curl -L -o logger.ts "$API_URL?file=lib/logger.ts"

# ✅ Vérification & déplacement des fichiers
if [[ -f "first-install.ts" && -f "first-install.tsx" ]]; then
  mkdir -p ./pages/api
  mkdir -p ./lib
  mv first-install.ts ./pages/api/lib-ellule/first-install.ts
  mv install-log.ts ./pages/api/lib-ellule/install-log.ts
  mv libellule.tsx ./pages/libellule.tsx
  mv libellule.module.css ./pages/api/lib-ellule/libellule.module.css
  mv logger.ts ./lib/logger.ts
  mv env.modele ./.env

  URL="http://$LOCALHOST/first-install"

  # Vérifications avant de lancer l'api
  read -p "
  🌟 Ton navigateur va s'ouvrir pour continuer l'installation de la bibliothèque Plasmic Libellule.

  Avant de poursuivre, voici quelques points à vérifier :
    1. Modifie le port dans le fichier .env
    2. Change le script dans package.json pour : npm run dev -p <leport>.
    3. Modifie plasmic-init.ts pour passer le paramètre preview à true.
    4. Exécute, dans un autre terminal, 'npm run dev'.

  Appuie sur Enter lorsque tu es prêt à continuer... "

  # 📦 Installer adm-zip et ses types
  if ! npm list adm-zip >/dev/null 2>&1; then
    echo "📦 Installation de adm-zip..."
    npm install adm-zip
    npm install --save-dev @types/adm-zip
  else
    echo "✅ adm-zip déjà installé"
  fi

  # Attendre la pression sur Entrée pour poursuivre
  read -p "Appuie sur Enter pour ouvrir le navigateur..."

  echo "🌐 Ouverture du navigateur sur $URL..."

  if grep -qi microsoft /proc/version; then
    # On est dans WSL
    powershell.exe start "$URL"
  else
    # Linux classique
    xdg-open "$URL" 2>/dev/null || sensible-browser "$URL" 2>/dev/null || gnome-open "$URL" 2>/dev/null || x-www-browser "$URL" 2>/dev/null
  fi

  echo "✅ Installation terminée avec succès !"
else
  echo "❌ Erreur : Les fichiers n'ont pas pu être téléchargés."
  exit 1
fi
