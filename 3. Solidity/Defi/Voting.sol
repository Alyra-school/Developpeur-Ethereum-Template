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

    WorkflowStatus public wfStatus = WorkflowStatus.RegisteringVoters;

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
    uint private _winningProposalId;
    

    /**
    * TODO :
    * RegisteringProposal : vérifier l'address bien présente dans la whitelist
    * Pour voter il faut accéder à la liste des propositions
    */
    
    modifier atStage(WorkflowStatus _status) {
        require(
            wfStatus == _status,
            "Function cannot be called at this time."
        );
        _;
    }
    // Go to the next stage after the function is done.
    /*modifier transitionNext() {
        _;
        nextStage();
    }*/

    function nextStage() internal {
        WorkflowStatus newStatus = WorkflowStatus(uint(wfStatus) + 1);
        emit WorkflowStatusChange(wfStatus,newStatus);
        wfStatus = newStatus;
    }

    /*
    *
    *   1) L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
    *
    */
    function registeringUniqueAd(address _address) public onlyOwner atStage(WorkflowStatus.RegisteringVoters){
        require(!comptesWL[_address].isRegistered,"Already registered in the whitelist my dear");
        //Création d'un Voter via Structure & Màj Whitelist address => struct
        Voter memory vote;
        vote.isRegistered = true;
        vote.hasVoted = false;
        comptesWL[_address] = vote;
        //Event électeur enregistré
        emit VoterRegistered(_address);
    }

    /*
    *
    *   1) L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
    *
    */
    function registeringWL(address[] memory arrayWL) public onlyOwner atStage(WorkflowStatus.RegisteringVoters){
        Voter memory vote;
        for(uint i=0;i<arrayWL.length;i++){
            vote = Voter(true,false,0);
            //Si l'adresse est déjà existante on écrase
            comptesWL[arrayWL[i]] = vote;
            emit VoterRegistered(arrayWL[i]);
        }
    }

    /* 
    *
    * 2) L'administrateur du vote commence la session d'enregistrement de la proposition.
    *
    */
    function startingProposalSession() public onlyOwner atStage(WorkflowStatus.RegisteringVoters){
        //WL terminée, on passe à l'étape d'apès
        nextStage();
    }

    /* 
    *
    *   3) Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
    *
    */
    function registeringProposal(string memory _description) public atStage(WorkflowStatus.ProposalsRegistrationStarted){
        
        listProposal[proposalId] = Proposal(_description,0);
        proposalId++;
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
        require(wfStatus == WorkflowStatus.ProposalsRegistrationStarted,"Registering proposal isn't started yet");
        //Changement de status
        emit WorkflowStatusChange(wfStatus,WorkflowStatus.ProposalsRegistrationEnded);
        wfStatus = WorkflowStatus.ProposalsRegistrationEnded;
    }

    /* 
    *
    *   5) L'administrateur du vote commence la session de vote.
    *
    */
    function startVotingSession() public onlyOwner{
        //On a bien fini la session de registration des proposals
        require(wfStatus == WorkflowStatus.ProposalsRegistrationEnded,"Registering proposal isn't finished yet");
        //On a au moins une proposition, sinon on vote pour rien
        require(proposalId >= 1,"Not enough proposition to start a vote");
        //Changement de status
        emit WorkflowStatusChange(wfStatus,WorkflowStatus.VotingSessionStarted);
        wfStatus = WorkflowStatus.VotingSessionStarted;
    }

    /* 
    *
    *   6) Les électeurs inscrits votent pour leurs propositions préférées.
    *
    */
    function votingFor(uint _proposalId) public{
        //la session de vote a démarré
        require(wfStatus == WorkflowStatus.VotingSessionStarted,"Voting session isn't started yet");
        //Droit de voter de msg.sender
        require(comptesWL[msg.sender].isRegistered && (comptesWL[msg.sender].hasVoted == false),"You are not allowed to vote or you already voted");        
        //Tester que le _proposalId existe vraiment
        require(proposalId >= _proposalId,"Proposal wished doesnt exist");

        //Mise à jour du "à voter"
        comptesWL[msg.sender].hasVoted = true;
        comptesWL[msg.sender].votedProposalId = _proposalId;

        //Mise à jour du count de vote pour la proposition votée
        listProposal[_proposalId].voteCount++;

        //emit
        emit Voted(msg.sender,_proposalId);
    }


    /* 
    *
    *   7) L'administrateur du vote met fin à la session de vote.
    *
    */
    function endVotingSession() public onlyOwner{
        //On a bien démarré la session de vote
        require(wfStatus == WorkflowStatus.VotingSessionStarted,"Voting isn't started yet, can't close it");
        //On a au moins un vote
        require(proposalId >= 1,"Not enough proposition to close the voting session");
        //Changement de status
        emit WorkflowStatusChange(wfStatus,WorkflowStatus.VotingSessionEnded);
        wfStatus = WorkflowStatus.VotingSessionEnded;
    }


    /* 
    *
    *   8) L'administrateur du vote comptabilise les votes.
    *
    */
    function countVote() public onlyOwner{
        require(wfStatus == WorkflowStatus.VotingSessionEnded,"Voting isn't finished yet");
        uint maxCount=listProposal[0].voteCount;
        for(uint i = 1;i<proposalId;i++){
            if(listProposal[i].voteCount > maxCount){
                maxCount = listProposal[i].voteCount;
                _winningProposalId = i;
            }
        }
        //Changement de status
        emit WorkflowStatusChange(wfStatus,WorkflowStatus.VotingSessionEnded);
        wfStatus = WorkflowStatus.VotesTallied;
    }

    function winningProposalId() public view returns(uint){
        require(wfStatus == WorkflowStatus.VotesTallied,"Vote counting isn't finished yet");
        return _winningProposalId;
    }


    /* 
    *
    *   9) Tout le monde peut vérifier les derniers détails de la proposition gagnante.
    *
    */
    function getWinner() public view returns(string memory){
        require(wfStatus == WorkflowStatus.VotesTallied,"Vote counting isn't finished yet");
        return listProposal[winningProposalId()].description;
    }

}
