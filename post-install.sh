#!/bin/bash

echo "📦 Démarrage du script de postinstallation..."

# Déterminer le chemin du répertoire projet
PROJECT_DIR2="../../.."
LIBRARY_DIR="."

if [ ! -d "$PROJECT_DIR2/libellule/" ]; then
  mkdir -p "$PROJECT_DIR2/libellule/"
  cp -r "$LIBRARY_DIR/libellule/." "$PROJECT_DIR2/libellule/"
  cp -r "$LIBRARY_DIR/libellule/.env.install.model" "$PROJECT_DIR2/.env.install"
  cp -r "$LIBRARY_DIR/libellule/package.json.model" "$PROJECT_DIR2/package.json"
fi

echo "✅  Installation réussie !"