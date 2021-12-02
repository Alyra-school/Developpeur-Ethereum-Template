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

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    event WhiteListed (address _address);
    event BlackListed (address _address);

    mapping (address => bool) private comptesWL;
    mapping (address => bool) private comptesBL;

    /*1) L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.*/
    function whitelist(address _address) public onlyOwner{
        require(!comptesWL[_address],"Already in the whitelist my dear");
        //Màj status enum

        //Création d'un Voter via Structure
        //Màj Whitelist address => struct
        comptesWL[_address] = true;
        emit WhiteListed(_address);
        emit VoterRegistered(_address); //Event électeur enregistré
    }

    function isWhiteListed(address _address) public view returns(bool){
        return comptesWL[_address];
    }

    function isBlackListed(address _address) public view returns(bool){
        return comptesBL[_address];
    }

    function winningProposalId() public pure returns(uint){
        return 1;
    }

    function getWinner() public pure returns(uint){
        return 1;
    }
}
