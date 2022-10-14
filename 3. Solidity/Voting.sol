// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 <0.9.0;

import "@OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {
    string currentStatus;

    struct Voter {
        bool isRegisted;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;

    }
    Proposal[] proposals;
    mapping(address => Voter) registeredVoters;
    mapping(Voter => Proposal) voterProposal;


    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    event VoterRegisteredEvent(address voterAddress);
    event WorkflowStatusChangeEvent(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistedEvent(uint proposalId);
    event VotedEvent(address voter, uint proposalId);

    function registerVoters(address[] votersAddress) onlyOwner public {
        for(uint i; i < votersAddress.length; i++) {
            tmpVoter = Voter();
            tmpVoter.isRegisted = true;
            tmpVoter.hasVoted = false;
            registeredVoters[votersAddress[i]] = tmpVoter;
            emit VoterRegisteredEvent(i);
        }
    }

    function voterProposal(string memory description, address voterAddress) public checkVoter {
        changeStatus(WorkflowStatus['RegisteringVoters'], WorkflowStatus['ProposalsRegistrationStarted']);

        proposals[] = Proposal(description);
    }

    function getWinner() public view returns(Proposal) {
        Proposal proposalWinner;
        for(uint i; i < proposals.length; i++) {
            if (!tmpWinner
                || tmpWinner.voteCount < proposals[i].voteCount
            ) {
                proposalWinner = proposals[i];
            }
        }

        return proposalWinner;
    }

    function changeStatus(WorkflowStatus _previousStatus, WorkflowStatus _newStatus) {
        emit WorkflowStatusChangeEvent(_previousStatus, _newStatus);
        currentStatus = _newStatus;
    }

    function submitVote(uint memory proposalId, address _address) public {
        changeStatus(WorkflowStatus['ProposalsRegistrationEnded'], WorkflowStatus['VotingSessionStarted']);
        registeredVoters;
    }

    modifier checkVoter(address _address) {
        require(registeredVoters[voterAddress].isRegistered == true, "Forbidden, u must be registered to continue");
        _;
    }

    modifier checkStatus(WorkflowStatus _workflowStatus) {

    }

    function getCurrentStatus() pure view public {
        return
    }
}