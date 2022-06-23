# Tests unitaires, CI/CD
Tester le bon fonctionnement d'une partie précise d'un programme

## Test d'intégrations avec Truffle, Mocha et Chai
Truffle utilise Mocha pour les tests et Chai pour les assertions
- [Mocha](https://mochajs.org/api/)
- [Chai](https://www.chaijs.com/api/)
- [Truffle test helpers](https://docs.openzeppelin.com/test-helpers/0.5/api)

Les tests doivent être écrits en .js et dans le repértoire ./test.
Le code sera reconnu par Mocha comme un test automatisé.

```bash
# Les tests pourront être lancé avec
truffle test

# Choisir le test
truffle test test/testfile.js

# Possibilité de choisir le réseau avec
truffle --network <nom du réseau>
```

## Installation complète
```bash
npm install @openzeppelin/test-helpers @openzeppelin/contracts @truffle/hdwallet-provider dotenv
```

---

## Truffle test helpers
```bash
# Installation
npm install --save-dev @openzeppelin/test-helpers
```

Tous les nombres retournés sont de type [BN](https://github.com/indutny/bn.js), (Big Number) [Safe use of BN](https://blog.enuma.io/update/2019/01/31/safe-use-of-bignumber.js.html)
- [artifacts.require](https://trufflesuite.com/docs/truffle/getting-started/running-migrations/#artifactsrequire)

  - Indiquer avec quel contrat intéragir
```js
const SimpleStorage = artifacts.require("SimpleStorage");
```

- [contract()](https://trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript/#use-contract-instead-of-describe)
  - contract() fonctionne de la même manière que describe() de Mocha à la différence que le contrat sera re déployé avant chaque appel de contract().
  - contract() fournit également la liste des comptes du client Ethereum utilisé.

```js
contract("SimpleStorage", (accounts) => {

})
```

- [expectEvent](https://docs.openzeppelin.com/test-helpers/0.5/api#expect-event)
  - confirme que les logs reçu contiennent un événement avec le nom 'eventName'
  - que les arguments correspondent à ceux spécifié par 'eventArgs'
  - le 'receipt' doit être un objet renvoyé soit par un contrat web3, soit par un appel truffle-contract

```js
// function expectEvent(receipt, eventName, eventArgs = {})
expectEvent(
    await simpleStorageInstance.set(new BN(12), { from: accounts[0] }), 
    "DataStored", 
    { _data: new BN(12), _address: owner }
);

```  

- [expectRevert](https://docs.openzeppelin.com/test-helpers/0.5/api#expect-revert)
```js
// async function expectRevert(promise, message)
await expectRevert(
    simpleStorageInstance.set(new BN(0), {from:owner}), 
    'vous ne pouvez pas mettre une valeur nulle'
);

```  

---

## Mocha - tests

- describe()
  - quelle fonctionnalité nous devons décrire
  - structure un ensemble de tests
  - regroupe les 'workers' comme it()

```js
describe("Type/nom du test", function () {
        
});
```

- [beforeEach()](https://mochajs.org/#hooks)
  - hooks 
  - sera exécuté avant chaque cas de test
  - initialise des conditions préalables avant chaque test
  - nettoyage après les tests
  
```js
// Dans ce cas ci, 
beforeEach(async function () {
    simpleStorageInstance = await SimpleStorage.new({from:owner});
});

```

- it()
  - décrire le test d'une façon lisible

```js
describe("Type/nom du test", function () {
    it("...should store the value 89.", async () => {
        // Tests
        // ...
    });
});
```

Possible de rajouter .skip ou .only

---

## Tchai - assertions
- [expect](https://www.chaijs.com/guide/styles/#expect)
  - permet de réaliser des assertions
  - possibilité de les chaîner

```js
// Importer expect
const { expect } = require('chai');

// Exemples
expect(foo).to.be.a('string');
expect(foo).to.equal('bar');
expect(foo).to.have.lengthOf(3);
expect(foo).to.be.false;
expect(foo).to.be.true;
```
___

## ETH Gas Reporter
Rapport sur la consommation de gas pour les tests avec Mocha
- [API](https://www.npmjs.com/package/eth-gas-reporter)
  
```bash
npm install --save-dev eth-gas-reporter 
```

A rajouter dans truffle-config.js dans mocha

```js
mocha: {
  // timeout: 100000
  reporter: 'eth-gas-reporter',
  reporterOptions : { 
    gasPrice:1,
    token:'ETH',
    showTimeSpent: true,
  }
},
```
___

## Solidity coverage
⚠️ Ne fonctionne pas sur les dernières versions de Ganache
- [API](https://github.com/sc-forks/solidity-coverage)
  
```bash
npm install solidity-coverage
```

A rajouter dans truffle-config.js

```js
plugins: ["solidity-coverage"],
```
____

## Intégration continue
[ETH doc](https://ethereum.org/fr/developers/tutorials/solidity-and-truffle-continuous-integration-setup/)
