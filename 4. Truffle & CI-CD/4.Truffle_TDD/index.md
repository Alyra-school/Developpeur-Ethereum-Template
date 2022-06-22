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

---

## Truffle test helpers
Tout les nombres retournés sont de type [BN](https://github.com/indutny/bn.js) (Big Number)
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

---

## Tchai - assertions
expect



```js

```