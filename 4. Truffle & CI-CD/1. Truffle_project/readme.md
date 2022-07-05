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