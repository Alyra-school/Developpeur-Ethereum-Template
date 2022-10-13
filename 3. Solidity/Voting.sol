// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.7.0 <0.9.0;

import "@OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {
    struct Voter {
        bool isRegisted;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;

    }

    mapping(address => Voter) registeredVoters;

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

    function registerVoters(address[] voterAddressed) onlyOwner public {
        for(uint i; i < voterAddressed.length; i++) {
            Voter memory tmpVoter;
            tmpVoter.isRegisted = true;
            tmpVoter.hasVoted = false;
            registeredVoters[i] = tmpVoter;
            emit VoterRegisteredEvent(i);
        }
    }

    function votersProposals

}