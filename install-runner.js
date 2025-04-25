const readline = require('readline');
const fs = require('fs');
const { execSync } = require('child_process');
const { platform } = require('os');
const path = require('path');

// Création du prompt
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Poser la question pour le domaine API
rl.question('🌐 Quel est le domaine de ton API (sans https://) ? ', (domaine) => {
  const apiUrl = `https://${domaine}/api/pre-install`;
  const envContent = `# URL de l'API pour télécharger les fichiers\nAPI_URL="${apiUrl}"\nLOCALHOST="localhost:3030"\n`;

  // Chemin vers la racine du projet (en partant du répertoire courant)
  const envPath = path.resolve(process.cwd(), '.env.install');

  try {
    fs.writeFileSync(envPath, envContent);
    console.log(`✅ Fichier .env.install créé à la racine avec :\n${envContent}`);
  } catch (err) {
    console.error('❌ Impossible de créer le fichier .env.install :', err.message);
    process.exit(1);
  }

  // Fermer l'interface readline et poursuivre avec le reste du script
  rl.close();

  // Le reste de ton script peut maintenant démarrer ici
  continueInstall();
});

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
