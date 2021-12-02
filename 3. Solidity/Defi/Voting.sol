// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

/*
    @admin : déploye le contrat
    1) L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
    2) L'administrateur du vote commence la session d'enregistrement de la proposition.
    3) Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
    4) L'administrateur de vote met fin à la session d'enregistrement des propositions.
    5) L'administrateur du vote commence la session de vote.
    6) Les électeurs inscrits votent pour leurs propositions préférées.
    7) L'administrateur du vote met fin à la session de vote.
    8) L'administrateur du vote comptabilise les votes.
    9) Tout le monde peut vérifier les derniers détails de la proposition gagnante.
*/
contract Voting is Ownable{
    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus private status;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    mapping (address => Voter) private comptesWL;
    mapping (uint => Proposal) private listProposal;
    uint public proposalId = 0;
    
    /*
    *
    *   1) L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
    *
    */
    function registeringWL(address _address) public onlyOwner{
        require(!comptesWL[_address].isRegistered,"Already registered in the whitelist my dear");
        
        //Prevoir de démarrer une campagne de vote, si elle existe déjà etc.

        emit WorkflowStatusChange (getEnumStatus(),WorkflowStatus.RegisteringVoters);

        //Création d'un Voter via Structure & Màj Whitelist address => struct
        Voter storage vote = comptesWL[_address];
        vote.isRegistered = true;
        vote.hasVoted = false;

        //Event électeur enregistré
        emit VoterRegistered(_address);
    }

    /* 
    *
    * 2) L'administrateur du vote commence la session d'enregistrement de la proposition.
    *
    */
    function startingProposalSession() public onlyOwner{
        //On a bien déjà démarré l'enregistrement des électeurs
        require(getEnumStatus() == WorkflowStatus.RegisteringVoters,"Registering of Voters isnt started yet");
        //Changement de status
        emit WorkflowStatusChange(getEnumStatus(),WorkflowStatus.ProposalsRegistrationStarted);
    }

    /* 
    *
    *   3) Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
    *
    */
    function registeringProposal(string memory _description) public{
        proposalId++;
        listProposal[proposalId] = Proposal(_description,0);
        //TODO Que se passe-t-il si plusieurs propositions sont les mêmes ?
        emit ProposalRegistered(proposalId);
    }

    /* 
    *
    *   4) L'administrateur de vote met fin à la session d'enregistrement des propositions.
    *
    */
    function endingProposalSession() public onlyOwner{
        //On avait bien démarré la session de proposal
        require(getEnumStatus() == WorkflowStatus.ProposalsRegistrationStarted,"Registering proposal isn't started yet");
        //Changement de status
        emit WorkflowStatusChange(getEnumStatus(),WorkflowStatus.ProposalsRegistrationEnded);
    }

    /* 
    *
    *   5) L'administrateur du vote commence la session de vote.
    *
    */
    function startingVotingSession() public onlyOwner{
        //On a bien fini la session de registration des proposals
        require(getEnumStatus() == WorkflowStatus.ProposalsRegistrationEnded,"Registering proposal isn't finished yet");
        //On a au moins une proposition, sinon on vote pour rien
        require(proposalId >= 1,"Not enough proposition to start a vote");
        //Changement de status
        emit WorkflowStatusChange(getEnumStatus(),WorkflowStatus.VotingSessionStarted);
    }

    /* 
    *
    *   6) Les électeurs inscrits votent pour leurs propositions préférées.
    *
    */
    function votingFor(uint _proposalId) public view returns(uint){
        //la session de vote a démarré
        require(getEnumStatus() == WorkflowStatus.VotingSessionStarted,"Voting session isn't started yet");
        //Droit de voter de msg.sender
        //Mise à jour du "à voter"
        //listProposal[proposalId]
        return _proposalId;
    }


    function winningProposalId() public pure returns(uint){
        return 1;
    }

    function getWinner() public pure returns(uint){
        return 1;
    }

    function getEnumStatus() private view returns(WorkflowStatus){
        return status;
    }
}
