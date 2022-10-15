// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8.17;

import "@OpenZeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    uint8 currentStep;
    uint8 stepDuration = 10;       // exprimed in bloc
    // Proposal[] proposals;

    struct Voter {
        bool isRegisted;
        bool hasVoted;
        uint16 votedProposalId;
    }

    struct Proposal {
        string description;
        uint16 voteCount;
    }

    address[] votersAddress;
    mapping(address => Voter) registeredVoters;
    mapping(address => Proposal[]) voterProposals;
    // mapping(uint16 => Proposal) proposals;


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

    /// @param _stepDuration the default timer duration
    constructor(uint8 _stepDuration) {
        if (_stepDuration != 0) {
            stepDuration = _stepDuration;
        }
        initializeStep();
    }

    /// @notice check if registered voter exists and is whitelisted
    modifier checkVoterAccess() {
        require(registeredVoters[msg.sender].isRegistered != false, "Forbidden, U must have been registered to continue");
        _;
    }

    /// @notice check step process
    modifier checkStep(uint _workflowStatus) {
        require(_workflowStatus == getCurrentStep(), "Forbidden, U can't do this now");
        _;
    }

    function storeAddressed(address _voterAddress) public onlyOwner {
        votersAddress.push(_voterAddress);
    }

    /// @notice register voters in a list
    function registerVoters() onlyOwner checkStep(WorkflowStatus.RegisteringVoters) public  {
        uint currentBloc = initializeCountdown();
        while(currentBloc < currentBloc + stepDuration) {
            for(uint i; i < votersAddress.length; i++) {
                tmpVoter = Voter();
                tmpVoter.isRegisted = true;
                tmpVoter.hasVoted = false;
                tmpVoter.votedProposalId = 0;
                registeredVoters[votersAddress[i]] = tmpVoter;
                emit VoterRegisteredEvent(votersAddress[i]);
            }
        }
    }

    /// @notice register a proposal
    /// @param _description the description of the proposal
    function submitProposal(string memory _description) public checkVoterAccess checkStep(WorkflowStatus.ProposalsRegistrationStarted) {
        uint currentBloc = initializeCountdown();
        while(currentBloc < currentBloc + stepDuration) {
            tmpProposal = Proposal();
            tmpProposal.description = _description;
            tmpProposal.voteCount = 0;
            // proposals[] = tmpProposal;
            voterProposals[msg.sender].push(tmpProposal);
            emit proposalRegistedEvent(tmpProposal);
        }
    }

    /// @notice vote for the proposals
    /// @param proposalId the id of the proposal
    function submitVote(uint memory proposalId) public checkVoterAccess checkStep(WorkflowStatus.VotingSessionStarted) {
        require(registeredVoters[msg.sender].hasVoted, "Forbidden, U have already voted");
        registeredVoters[msg.sender].votedProposalId = proposalId;
        registeredVoters[msg.sender].hasVoted = true;
        // find proposal and increment voteCount
    }

    /// @notice get the proposal who wins with the greater number of vote
    /// @return proposalWinner the contest winner !
    function getWinner() public onlyowner checkStep(WorkflowStatus.VotesTallied) view returns (Proposal proposalWinner) {
        emit VotedEvent(voterId, proposalId);
        Proposal proposalWinner;
        for(uint i; i < proposals.length; i++) {
            if (!proposalWinner
                || proposalWinner.voteCount < proposals[i].voteCount
            ) {
                proposalWinner = proposals[i];
            }
        }

        return proposalWinner;
    }

    /// @notice change the step
    /// @param _previousStatus The old status to change
    /// @param _newStatus the new status to apply
    /// @return currentStep current step
    function changeStep(WorkflowStatus _previousStatus, WorkflowStatus _newStatus) public onlyOwner returns (string currentStep){
        setCurrentStep(_newStatus);
        emit WorkflowStatusChangeEvent(_previousStatus, _newStatus);
        return _newStatus;
    }

    /// @notice return current step
    /// @return currentStep current step
    function getCurrentStep() pure internal returns(uint8 currentStep) {
        return currentStep;
    }

    /// @notice set current step
    function setCurrentStep(uint8 memory _newStatus) internal {
        currentStep = _newStatus;
    }

    /// @notice initialize first step
    function initializeStep() internal returns(uint8 currentStep) {
        setCurrentStep(WorkflowStatus.RegisteringVoters);
    }

    /// @notice set the timer for a step
    function initializeCountdown() internal pure returns (uint blockNumber) {
        return block.number;
    }

    /// @notice return voters with proposal
    function seeVote() pure checkVoterAccess public returns(RegisterdVoters registeredVoters) {
        return registeredVoters;
    }

    function clearVotersRights() {
        for(uint16 i; i <= votersAddress.length; i++) {
            registeredVoters[votersAddress[i]].isRegisted = false;
            registeredVoters[votersAddress[i]].votedProposalId = 0;
        }
    }
}