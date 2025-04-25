const { execSync } = require('child_process');
const { platform } = require('os');
const fs = require('fs');
const path = require('path');

// Récupérer le répertoire racine du projet
const projectRoot = process.cwd();
const libellulePath = path.join(projectRoot, 'libellule');

function copyFileToLibellule(file) {
  const src = path.join(__dirname, file);
  const dest = path.join(libellulePath, file);
  fs.copyFileSync(src, dest);
  console.log(`📄 Copié ${file} → libellule/`);
}

try {
  // Changer le répertoire de travail à la racine du projet
  process.chdir(projectRoot);

  // 📁 Créer le dossier libellule s'il n'existe pas
  if (!fs.existsSync(libellulePath)) {
    fs.mkdirSync(libellulePath);
    console.log('📁 Dossier libellule créé à la racine du projet.');
  }

  // 📄 Copier les fichiers du package vers libellule
  copyFileToLibellule('install.sh');
  copyFileToLibellule('install.ps1');
  copyFileToLibellule('install-runner.js');

  // 📦 Installer les dépendances nécessaires
  if (!fs.existsSync('node_modules/dotenv')) {
    execSync('npm install dotenv', { stdio: 'inherit' });
  }

  if (!fs.existsSync('node_modules/adm-zip')) {
    execSync('npm install adm-zip', { stdio: 'inherit' });
    execSync('npm i --save-dev @types/adm-zip', { stdio: 'inherit' });
  }

  // ▶️ Lancer le script depuis le nouveau dossier
  process.chdir(libellulePath);  // Se déplacer dans libellule pour exécuter le script

  if (platform() === 'win32') {
    console.log('🪟 Exécution de install.ps1 depuis libellule/');
    execSync('powershell -ExecutionPolicy Bypass -File ./install.ps1', { stdio: 'inherit' });
  } else {
    console.log('🐧 Exécution de install.sh depuis libellule/');
    execSync('chmod +x ./install.sh');
    execSync('bash ./install.sh', { stdio: 'inherit' });
  }

} catch (error) {
  console.error('❌ Erreur pendant le postinstall :', error.message);
  process.exit(1);
}
