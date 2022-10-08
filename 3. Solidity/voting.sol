// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    mapping (address => Voter) whitelist;
    WorkflowStatus status = WorkflowStatus.RegisteringVoters;
    Proposal[] proposals;
    uint winningProposalId;

    modifier checkStatus(WorkflowStatus _status) {
        require(status == _status, "Invalid workflow status");
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender].isRegistered, "You are not in the whitelist");
        _;
    }

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    function addVoter(address _addr) public onlyOwner checkStatus(WorkflowStatus.RegisteringVoters) {
        require(!whitelist[_addr].isRegistered, "Already whitelisted");
        whitelist[_addr] = Voter(true, false, 0);
        emit VoterRegistered(msg.sender);
    }

    function startProposalsRegistration() public onlyOwner checkStatus(WorkflowStatus.RegisteringVoters) {
        status = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, status);
    }

    function emitProposal(string memory _description) public onlyWhitelisted checkStatus(WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push(Proposal(_description, 0));
        emit ProposalRegistered(proposals.length - 1);
    }

    function endProposalsRegistration() public onlyOwner checkStatus(WorkflowStatus.ProposalsRegistrationStarted) {
        status = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, status);
    }

    function startVotingSession() public onlyOwner checkStatus(WorkflowStatus.ProposalsRegistrationEnded) {
        status = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, status);
    }

    function vote(uint _proposalId) public onlyWhitelisted checkStatus(WorkflowStatus.VotingSessionStarted) {
        require(!whitelist[msg.sender].hasVoted, "You have already voted");
        require(_proposalId < proposals.length, "No proposal matching this id");
        proposals[_proposalId].voteCount ++;
        whitelist[msg.sender].hasVoted = true;
        whitelist[msg.sender].votedProposalId = _proposalId;
        emit Voted(msg.sender, _proposalId);
    }

    function endVotingSession() public onlyOwner checkStatus(WorkflowStatus.VotingSessionStarted) {
        status = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, status);
    }

    function votesTally() public onlyOwner checkStatus(WorkflowStatus.VotingSessionEnded) {
        for(uint i=0; i<proposals.length; i++){
            if(proposals[i].voteCount > winningProposalId) {
                winningProposalId = i;
            }
        }
        status = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, status);
    }

    function getWinner() public view checkStatus(WorkflowStatus.VotesTallied) returns(uint) {
        return winningProposalId;
    }

    function getStatus() public view returns(string memory) {
        if(status == WorkflowStatus.RegisteringVoters){
            return "RegisteringVoters";
        } else if(status == WorkflowStatus.ProposalsRegistrationStarted){
            return "ProposalsRegistrationStarted";
        } else if(status == WorkflowStatus.ProposalsRegistrationEnded){
            return "ProposalsRegistrationEnded";
        } else if(status == WorkflowStatus.VotingSessionStarted){
            return "VotingSessionStarted";
        } else if(status == WorkflowStatus.VotingSessionEnded){
            return "VotingSessionEnded";
        } else {
            return "VotesTallied";
        } 
    }

}
