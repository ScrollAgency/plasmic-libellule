const { execSync } = require('child_process');
const { platform } = require('os');
const fs = require('fs');
const path = require('path');

// 🔁 Aller à la racine du projet
const projectRoot = path.resolve(__dirname, '../../../');
process.chdir(projectRoot);

console.log('📁 Racine du projet :', process.cwd());
try {
  // Vérifier si dotenv est déjà installé
  const isDotenvInstalled = fs.existsSync('node_modules/dotenv');

  if (!isDotenvInstalled) {
    console.log('📦 dotenv non trouvé. Installation en cours...');
    execSync('npm install dotenv', { stdio: 'inherit' });
  } else {
    console.log('✔️ dotenv déjà installé.');
  }

  // Vérifier si adm-zip est déjà installé
  const isAdmZipInstalled = fs.existsSync('node_modules/adm-zip');
  if (!isAdmZipInstalled) {
    console.log('📦 adm-zip non trouvé. Installation en cours...');
    execSync('npm install adm-zip', { stdio: 'inherit' });
    console.log('📦 Installation de @types/adm-zip en mode dev...');
    execSync('npm i --save-dev @types/adm-zip', { stdio: 'inherit' });
  } else {
    console.log('✔️ adm-zip déjà installé.');
  }

  // Exécution du script d'installation selon la plateforme
  if (platform() === 'win32') {
    console.log('Détection de Windows : exécution de install.ps1');
    execSync('powershell -ExecutionPolicy Bypass -File ./install.ps1', { stdio: 'inherit' });
  } else {
    console.log('Détection de Linux/macOS : ajout des droits d’exécution + lancement de install.sh');
    execSync('chmod +x ./install.sh');
    execSync('bash ./install.sh', { stdio: 'inherit' });
  }

} catch (error) {
  console.error('Erreur pendant le postinstall :', error.message);
  process.exit(1);
}
