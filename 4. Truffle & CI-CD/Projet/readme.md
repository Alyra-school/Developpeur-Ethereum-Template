# Projet 2. Tests unitaires pour le contrat Voting.sol

J'ai séparé les tests en section de la même façon que le contrat Voting.sol.
À chaque section, je commence par tester les modifiers, only owner ou only voters

___

## 26 tests ont été réalisés

### 1. Getters
- Doit pouvoir utiliser les getters si on est un voter
- Doit retourner la structure d'un voter
- Doit retourner une proposition à partir d'un id
___
### 2. Registration
- Doit être le propriétaire du contrat pour ajouter un voter
- Doit avoir la session d'enregistrement démarré
- Doit refuser un second enregistrement d'une même addresse
- Doit émettre l'enregistrement d'une nouvelle adresse
___
### 3. Proposal
- Doit être un voter pour ajouter une proposition
- Doit échouer si la session n'a pas commencé
- Doit échouer si la proposition est vide
- Doit émettre l'id de la dernière proposition ajouté
___
### 4. Vote
J'ai utiliser un before pour pour faire une procédure de vote normal et tester l'interdiction de voter une seconde fois
- Doit être un voter pour voter
- Doit avoir la session de vote démarré
- Doit voter pour émettre l'id du vote
- Doit avoir voté qu'une fois
- Doit voter pour un id existant
___
### 5. State
- Doit être le propriétaire du contrat pour modifier les enums
- Doit pouvoir commencer une session de propositions, 0 à 1
- Doit pouvoir mettre fin à une session de proposition, 1 à 2
- Doit pouvoir commencer une session de vote, 2 à 3
- Doit pouvoir mettre fin à une session de vote, 3 à 4
___
### 6. Tally votes
- Doit être le propriétaire du contrat pour lancer le tri
- Doit avoir la session de vote terminé
- Doit avoir winningProposalId = à la meilleure proposition
- Doit changer le workflowStatus en vote trié, 4 à 5
___
## Coverage
Taux de couverture des tests
| File       | % Stmts | % Branch | % Funcs | % Lines | Uncovered Lines |
| ----       | ------: | -------: | ------: | ------: | --------------: |
| contracts/ | 97.44   | 82.14    |  100    | 97.56   |                 |
| Voting.sol | 97.44   | 82.14    |  100    | 97.56   | 129             |
| All files  | 97.44   | 82.14    |  100    | 97.56   |                 |
