// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";


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

    function updateStatus(WorkflowStatus _newStatus) public onlyOwner {
        require(status != _newStatus, "You are already in this status");
        require(status == WorkflowStatus(uint(_newStatus)-1), "You can not switch to this status. You are not in the appropriate status");
        if(_newStatus == WorkflowStatus.ProposalsRegistrationStarted){
            proposals.push(Proposal("Genesys", 0));
        } else if(_newStatus == WorkflowStatus.ProposalsRegistrationEnded){
            require(proposals.length > 1, "Minimum one proposal must be sent");
        } else if(_newStatus == WorkflowStatus.VotesTallied){
            for(uint i=1; i<proposals.length; i++){
            if(proposals[i].voteCount > winningProposalId) {
                winningProposalId = i;
            }
        }
        } else if(_newStatus == WorkflowStatus.RegisteringVoters) {
            revert("You can not return to RegisteringVoters status");
        }
        WorkflowStatus pastStatus = status;
        status = _newStatus;
        emit WorkflowStatusChange(pastStatus, status);
    }

    function emitProposal(string memory _description) public onlyWhitelisted checkStatus(WorkflowStatus.ProposalsRegistrationStarted) {
        proposals.push(Proposal(_description, 0));
        emit ProposalRegistered(proposals.length - 1);
    }

    function vote(uint _proposalId) public onlyWhitelisted checkStatus(WorkflowStatus.VotingSessionStarted) {
        require(!whitelist[msg.sender].hasVoted, "You have already voted");
        require(_proposalId > 0, "The id must be strictly superior to 0");
        require(_proposalId < proposals.length, string.concat("No proposal matching this id. The id must be strictly inferior to ", Strings.toString(proposals.length)));
        proposals[_proposalId].voteCount ++;
        whitelist[msg.sender].hasVoted = true;
        whitelist[msg.sender].votedProposalId = _proposalId;
        emit Voted(msg.sender, _proposalId);
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
