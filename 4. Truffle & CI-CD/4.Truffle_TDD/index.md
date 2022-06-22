# Tests unitaires, CI/CD
Tester le bon fonctionnement d'une partie précise d'un programme

## Test d'intégrations avec Truffle, Mocha et Chai
Truffle utilise Mocha pour les tests et Chai pour les assertions
- [Mocha](https://mochajs.org/api/)
- [Chai](https://www.chaijs.com/api/)

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

## Truffle
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

---

## Mocha - tests
- describe()
  - Quelle fonctionnalité nous devons décrire
  - structure un ensemble de tests
  - regroupe les 'workers' comme it()

```js
describe("Type/nom du test", function () {
        
});
```

- it()
  - décrire le test d'une façon lisible
```js
describe("Type/nom du test", function () {
    it("...should store the value 89.", async () => {
        await simpleStorageInstance.set(89, { from: owner });
        const storedData = await simpleStorageInstance.get.call();
        expect(new BN(storedData)).to.be.bignumber.equal(new BN(89));
    });
});
```

beforeEach()


---

## Tchai - assertions
```js

```