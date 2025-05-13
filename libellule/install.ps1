# ⚠️ Autoriser l'exécution des scripts dans cette session
Set-ExecutionPolicy Bypass -Scope Process -Force

# ✅ Charger les variables d’environnement depuis .env
if (Test-Path ".env.install") {
    Get-Content ".env.install" | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]+)=(.*)$") {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim().Trim('"')
            Set-Item -Path "env.install:$name" -Value $value
        }
    }
} else {
    Write-Host "⚠️ Fichier .env.install introuvable. Veuillez en créer un à partir de env.install.modele."
    exit 1
}

# 🧰 Demander à l'utilisateur s’il souhaite installer Plasmic
$installPlasmic = Read-Host "Souhaites-tu installer Plasmic ? (o/n)"

if ($installPlasmic -match "^[oOyY]$") {
    $monapp = Read-Host "Indique le nom de ton projet Plasmic"
    if (-not $monapp) {
        Write-Host "❌ Nom du projet invalide. Abandon."
        exit 1
    }

    Write-Host "📦 Création du projet $monapp avec create-plasmic-app..."
    npx create-plasmic-app $monapp

    Set-Location $monapp
} else {
    Write-Host "⏭️ Installation de Plasmic ignorée."
}

# 🧼 Supprimer les anciens fichiers s’ils existent
Remove-Item -Force -ErrorAction SilentlyContinue "tsconfig.json", "next.config.mjs"

# 📥 Télécharger les fichiers
$files = @(
    "pages/api/first-install.ts",
    "pages/first-install.tsx",
    "tsconfig.json",
    "next.config.mjs",
    "env.modele"
)

foreach ($file in $files) {
    $url = "$env:API_URL?file=$file"
    $output = Split-Path -Leaf $file
    Write-Host "⬇️ Téléchargement de $file..."
    try {
        Invoke-WebRequest -Uri $url -OutFile $output -ErrorAction Stop
    } catch {
        Write-Host "❌ Erreur : Impossible de télécharger $file"
    }
}

# ✅ Vérifier & déplacer les fichiers
if (Test-Path "first-install.ts" -and Test-Path "first-install.tsx") {
    New-Item -ItemType Directory -Force -Path ".\pages\api" | Out-Null
    Move-Item -Force "first-install.ts" ".\pages\api\first-install.ts"
    Move-Item -Force "first-install.tsx" ".\pages\first-install.tsx"
    Move-Item -Force "env.modele" ".\.env"

    # 📝 Demander la validation avant de lancer l'API
    Read-Host -Prompt "Ton navigateur va s'ouvrir afin de procéder à la suite de l'installation de la librairie Plasmic Libellule.
    Mais avant, vérifions quelques points :
    1. Définit le port utilisé dans ton .env.
    2. Change le script dans package.json pour : npm run dev -p <leport>.
    3. Modifie plasmic-init.ts pour passer le paramètre preview à true.
    4. Exécute, dans un autre terminal, 'npm run dev'.
    Appuie sur Enter lorsque tu es prêt à continuer..."

    # 📦 Installer adm-zip et ses types si nécessaire
    try {
        npm list adm-zip | Out-Null
        Write-Host "✅ adm-zip déjà installé"
    } catch {
        Write-Host "📦 Installation de adm-zip..."
        npm install adm-zip
        npm install --save-dev @types/adm-zip
    }

    # Ouvrir le navigateur
    $url = "http://$env:LOCALHOST/first-install"
    Write-Host "🌐 Ouverture du navigateur sur $url..."
    Start-Process $url

    Write-Host "✅ Installation terminée avec succès !"
} else {
    Write-Host "❌ Erreur : Les fichiers n'ont pas pu être téléchargés."
    exit 1
}
