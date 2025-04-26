const { execSync } = require('child_process');
const { platform } = require('os');
const fs = require('fs');
const path = require('path');

try {
  // 📦 Installer les dépendances nécessaires
  if (!fs.existsSync('node_modules/dotenv')) {
    execSync('npm install dotenv', { stdio: 'inherit' });
  }

  if (!fs.existsSync('node_modules/adm-zip')) {
    execSync('npm install adm-zip', { stdio: 'inherit' });
    execSync('npm i --save-dev @types/adm-zip', { stdio: 'inherit' });
  }

  if (platform() === 'win32') {
    console.log('🪟 Exécution de install.ps1 depuis libellule/');
    execSync('powershell -ExecutionPolicy Bypass -File libellule/install.ps1', { stdio: 'inherit' });
  } else {
    console.log('🐧 Exécution de install.sh depuis libellule/');
    execSync('chmod +x libellule/install.sh');
    execSync('bash libellule/install.sh', { stdio: 'inherit' });
  }

} catch (error) {
  console.error('❌ Erreur pendant le postinstall :', error.message);
  process.exit(1);
}
