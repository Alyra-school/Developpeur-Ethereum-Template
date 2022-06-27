# Découverte de Truffle
### Truffle est un framework de développement.
https://trufflesuite.com/docs/truffle/
___

### Installation et initialisation
```bash
# Installer truffle
npm install -g truffle

# Version installée
truffle version

# Initialiser un projet
truffle init
```

### Configuration
Dans le fichier truffle-config.js, dé-commenter le network de développement.

### Compilation et déploiement sur Ganache
```bash
# Lancer ganache avec mnemonic
ganache -m

# Compilation
truffle compile

# Déploiement
truffle deploy

# Compilation + déploiement
truffle migrate

# En cas d'erreur
truffle migrate --reset
```

### Console truffle
```bash
# Lancer la console
truffle console

# Possibilité de choisir le network
truffle console --network ropsten

# Récupérer l'instance du contrat déployé
const instance = await SimpleStorage.deployed()
```

### Wallet CLI
Rendre notre wallet disponible dans Truffle pour communiquer avec les blockchains
```bash
# HD Wallet provider, produit par ConcenSys
npm install @truffle/hdwallet-provider
```

### Provider RPC
Plateforme permettant l'accès aux blockchains, permet une connexion au réseau sans avoir besoin de son propre noeud.

Utilisation de Infura : https://infura.io/

### Dotenv
```bash
# Pouvoir utiliser des variables d'environnements, à mettre dans gitignore .env
npm install --save dotenv
```
- INFURA_ID = api keya
- MNEMONIC = passphrase

### Configurer le nouveau réseau dans truffle-config.js
```js
// Import de hdwallet et dotenv
const HDWalletProvider = require('@truffle/hdwallet-provider'); 
require('dotenv').config();

// Dans networks
ropsten:{
    provider : function () {
    return new HDWalletProvider({
        mnemonic:{phrase:`${process.env.MNEMONIC}`},
        providerOrUrl:`https://ropsten.infura.io/v3/${process.env.INFURA_ID}`
    })},
    network_id:3,
},
```

### Déploiement sur le réseau Ropsten
```bash
truffle migrate --network ropsten
```