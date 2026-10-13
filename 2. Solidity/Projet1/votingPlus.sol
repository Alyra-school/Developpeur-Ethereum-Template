// Licence MIT pour le contrat
// SPDX-License-Identifier: MIT

// Définition de la version du compilateur Solidity à utiliser
pragma solidity 0.8.13;

// Import du contrat Ownable d'OpenZeppelin qui gère les permissions
import "@openzeppelin/contracts/access/Ownable.sol";

// Définition du contrat Voting qui hérite des fonctionnalités de Ownable
contract Voting is Ownable {
    // Tableau qui stocke les IDs des propositions gagnantes (en cas d'égalité)
    uint[] winningProposalsID;
    // Tableau qui stocke les propositions gagnantes
    Proposal[] winningProposals;
    
    // Structure qui définit les propriétés d'un votant
    struct Voter {
        // Booléen indiquant si le votant est enregistré dans le système
        bool isRegistered;
        // Booléen indiquant si le votant a déjà voté
        bool hasVoted;
        // Identifiant de la proposition pour laquelle le votant a voté
        uint votedProposalId;
    }

    // Structure qui définit les propriétés d'une proposition
    struct Proposal {
        // Description textuelle de la proposition
        string description;
        // Compteur du nombre de votes reçus par la proposition
        uint voteCount;
    }

    // Énumération qui définit tous les états possibles du processus de vote
    enum  WorkflowStatus {
        // État initial : enregistrement des votants
        RegisteringVoters,
        // État : début de l'enregistrement des propositions
        ProposalsRegistrationStarted,
        // État : fin de l'enregistrement des propositions
        ProposalsRegistrationEnded,
        // État : début de la session de vote
        VotingSessionStarted,
        // État : fin de la session de vote
        VotingSessionEnded,
        // État final : votes comptabilisés
        VotesTallied
    }

    // Variable publique qui stocke l'état actuel du workflow
    WorkflowStatus public workflowStatus;
    // Tableau dynamique qui stocke toutes les propositions
    Proposal[] proposalsArray;
    // Mapping qui associe chaque adresse à un votant
    mapping (address => Voter) voters;

    // Événement émis quand un nouveau votant est enregistré
    event VoterRegistered(address voterAddress); 
    // Événement émis quand l'état du workflow change
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    // Événement émis quand une nouvelle proposition est enregistrée
    event ProposalRegistered(uint proposalId);
    // Événement émis quand un votant vote
    event Voted (address voter, uint proposalId);

    // Modificateur qui vérifie si l'appelant est un votant enregistré
    modifier onlyVoters() {
        // Vérifie si l'adresse de l'appelant est enregistrée comme votant
        require(voters[msg.sender].isRegistered, "You're not a voter");
        // Continue l'exécution de la fonction si la condition est remplie
        _;
    }
    
    // on peut faire un modifier pour les états

    // ::::::::::::: GETTERS ::::::::::::: //

    // Fonction qui retourne les informations d'un votant spécifique
    function getVoter(address _addr) external onlyVoters view returns (Voter memory) {
        // Retourne les informations du votant à l'adresse spécifiée
        return voters[_addr];
    }
    
    // Fonction qui retourne les informations d'une proposition spécifique
    function getOneProposal(uint _id) external onlyVoters view returns (Proposal memory) {
        // Retourne la proposition à l'index spécifié
        return proposalsArray[_id];
    }

 
    // ::::::::::::: REGISTRATION ::::::::::::: // 

    // Fonction pour ajouter un nouveau votant (accessible uniquement par le propriétaire)
    function addVoter(address _addr) external onlyOwner {
        // Vérifie si on est dans la phase d'enregistrement des votants
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');
        // Vérifie si le votant n'est pas déjà enregistré
        require(voters[_addr].isRegistered != true, 'Already registered');
    
        // Enregistre le votant
        voters[_addr].isRegistered = true;
        // Émet l'événement d'enregistrement
        emit VoterRegistered(_addr);
    }
 
    
    // Fonction pour supprimer un votant (accessible uniquement par le propriétaire)
    function deleteVoter(address _addr) external onlyOwner {
        // Vérifie si on est dans la phase d'enregistrement des votants
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');
        // Vérifie si le votant est bien enregistré
        require(voters[_addr].isRegistered == true, 'Not registered.');
        // Désactive l'enregistrement du votant
        voters[_addr].isRegistered = false;
        // Émet l'événement de modification du statut du votant
        emit VoterRegistered(_addr);
    }

    // ::::::::::::: PROPOSAL ::::::::::::: // 

    // Fonction pour ajouter une nouvelle proposition
    function addProposal(string memory _desc) external onlyVoters {
        // Vérifie si on est dans la phase d'enregistrement des propositions
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, 'Proposals are not allowed yet');
        // Vérifie que la description n'est pas vide
        require(keccak256(abi.encode(_desc)) != keccak256(abi.encode("")), 'Vous ne pouvez pas ne rien proposer');

        // Crée une nouvelle proposition
        Proposal memory proposal;
        // Définit la description de la proposition
        proposal.description = _desc;
        // Ajoute la proposition au tableau
        proposalsArray.push(proposal);
        // Émet l'événement d'enregistrement de la proposition
        emit ProposalRegistered(proposalsArray.length-1);
    }

    // ::::::::::::: VOTE ::::::::::::: //

    // Fonction pour voter pour une proposition
    function setVote( uint _id) external onlyVoters {
        // Vérifie si on est dans la phase de vote
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        // Vérifie si le votant n'a pas déjà voté
        require(voters[msg.sender].hasVoted != true, 'You have already voted');
        // Vérifie si l'ID de la proposition est valide
        require(_id < proposalsArray.length, 'Proposal not found');

        // Enregistre le vote du votant
        voters[msg.sender].votedProposalId = _id;
        // Marque le votant comme ayant voté
        voters[msg.sender].hasVoted = true;
        // Incrémente le compteur de votes de la proposition
        proposalsArray[_id].voteCount++;

        // Émet l'événement de vote
        emit Voted(msg.sender, _id);
    }

    // ::::::::::::: STATE ::::::::::::: //

    // Modificateur qui vérifie l'état du workflow
    modifier checkWorkflowStatus(uint  _num) {
        // Vérifie si l'état actuel correspond à l'état précédent attendu
        require (workflowStatus==WorkflowStatus(uint(_num)-1), "bad workflowstatus");
        // Vérifie qu'on ne passe pas directement à l'état 5 (VotesTallied)
        require (_num != 5, "il faut lancer tally votes");
        _;
    }
    
    // Fonction pour définir manuellement l'état du workflow
    function setWorkflowStatus(uint _num) external checkWorkflowStatus(_num) onlyOwner {
        // Sauvegarde l'ancien état
        WorkflowStatus old = workflowStatus;
        // Définit le nouvel état
        workflowStatus = WorkflowStatus(_num);
        // Émet l'événement de changement d'état
        emit WorkflowStatusChange(old, workflowStatus);
    } 
    
    // Fonction pour passer à l'état suivant du workflow
    function nextWorkflowStatus() external onlyOwner{
        // Vérifie qu'on n'est pas à l'état 4 (VotingSessionEnded)
        require (uint(workflowStatus)!=4, "il faut lancer tallyvotes");
        // Sauvegarde l'ancien état
        WorkflowStatus old = workflowStatus;
        // Passe à l'état suivant
        workflowStatus= WorkflowStatus(uint (workflowStatus) + 1);
        // Émet l'événement de changement d'état
        emit WorkflowStatusChange(old, workflowStatus);
    }
        

    // Fonction pour comptabiliser les votes en cas d'égalité (retourne un tableau)
    function tallyVotesDraw() external onlyOwner returns (uint[] memory){
        // Vérifie si on est dans la phase de fin de session de vote
        require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
        // Variable pour stocker le nombre de votes le plus élevé
        uint highestCount;
        // Compteur du nombre de gagnants
        uint nbWinners;
        // Index temporaire pour le tableau des gagnants
        uint temp;
        // Premier passage : compte le nombre de gagnants
        for (uint i = 0; i < proposalsArray.length; i++) {
            // Si égalité avec le meilleur score
            if (proposalsArray[i].voteCount == highestCount) {
                nbWinners++;
            }
            // Si nouveau meilleur score
            if (proposalsArray[i].voteCount > highestCount) {
                highestCount = proposalsArray[i].voteCount;
                nbWinners=1;
            }
        }
        // Crée un tableau de la taille du nombre de gagnants
        uint[] memory winners = new uint[](nbWinners);

        // Deuxième passage : remplit le tableau des gagnants
        for (uint h=0; h< proposalsArray.length; h++) {
            if (proposalsArray[h].voteCount == highestCount) {
                winners[temp] = h;
                temp++;
            }
        }
        // Change l'état vers la fin du processus
        workflowStatus = WorkflowStatus.VotesTallied;
        // Émet l'événement de changement d'état
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

        // Retourne le tableau des gagnants
        return winners;
    }

    // Fonction alternative pour comptabiliser les votes en cas d'égalité
    function tallyDraw() external onlyOwner{
        // Vérifie si on est dans la phase de fin de session de vote
        require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
        // Variable pour stocker le nombre de votes le plus élevé
        uint highestCount;
        
        // Premier passage : trouve le meilleur score
        for (uint i = 0; i < proposalsArray.length; i++) {
            if (proposalsArray[i].voteCount > highestCount) {
                highestCount = proposalsArray[i].voteCount;
            }
        }
        
        // Deuxième passage : ajoute tous les gagnants au tableau
        for (uint j = 0; j < proposalsArray.length; j++) {
            if (proposalsArray[j].voteCount == highestCount) {
                winningProposalsID.push(j);
            }
        }

        // Change l'état vers la fin du processus
        workflowStatus = WorkflowStatus.VotesTallied;
        // Émet l'événement de changement d'état
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }
}