// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

/** @title A whitelisting voting contract
    @notice This contract offer a voting system with: 
            - an admin, the contract owner
            - voters, with registered address by the admin
            Voters can first submit differents proposal about a topic.
            In a second time, Voters can vote one time for their favorite proposal 
            The proposal with the most votes will be the adopted solution 
    @author Loïs L.
    @custom:alyra This contract is created as a training excrcise (https://alyra.fr/) */
contract Voting is Ownable {
    /** @notice Store the ID of the most voted proposal 
        @dev will be 0 before 'VoteTailling()' call */
    uint public winningProposalId;
    /** @notice Store how many proposal has been proposed */
    uint proposalCount;
    /** @notice Index a 'Voter' to his address */
    mapping (address => Voter) private addressToVoter;
    /** @notice Index a 'Proposal' to his ID*/
    mapping (uint => Proposal) private proposalIdToProposal;
    /** @notice Define the current state of the Voting */
    WorkflowStatus currentState;
    /** @notice Define the structure of a Voter
        @param isRegistered Define if the voter is in the whitelist 
        @dev is false by default, true when added to the whitelist with the function 'registerVoter()'
        @param hasVoted Define if the voter has voted 
        @dev is false by default, true when the voter voted with 'vote()' 
        @param votedProposalId Store the ID of the voted proposal */
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    /** @notice Define the structure of a Proposal
        @param description Store the description the proposal 
        @param voteCount Store the number of voter who voted for the proposal */
    struct Proposal {
        string description;
        uint voteCount;
    }
    /** @notice Define the states possibilities 
        @param RegisteringVoters State where the admin can add the address as a voter in whitelist 
        @param ProposalRegistrationStarted State where Voter can register a proposal 
        @param ProposalRegistrationEnded State where the admin lock the proposal register 
        @param VotingSessionStarted State where voter can vote for his favorite proposal 
        @param VotingSessionEnded State where admin end the voting session
        @param VotesTallied State where the votes are counted and the winner is determined */
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    constructor(){
        currentState = WorkflowStatus.RegisteringVoters;
        proposalCount = 1;
    }

    /** @notice verify if the sender address is registered as a voter */
    modifier onlyRegistered(){
        require(addressToVoter[msg.sender].isRegistered == true, "address not registered as voter");
        _;
    }

    /** @notice Admin can register a voter by calling this function
        @param _voter the address of the whitelisted voter */
    function registerVoter(address _voter) external onlyOwner {
        addressToVoter[_voter] = Voter(true, false, 0);
        emit VoterRegistered(_voter);
    }

    /** @notice end the whitelisting period of voters by the admin */
    function endVoterRegister() external onlyOwner {
        require(currentState == WorkflowStatus.RegisteringVoters, "innapropriate time call");
        currentState = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, currentState);
    }

    /** @notice Voter can register a new proposal
        @param _desc the description of the proposal */
    function registerProposal(string memory _desc) external onlyRegistered {
        require(currentState == WorkflowStatus.ProposalsRegistrationStarted, "Proposal registration not opened");
        require(keccak256(abi.encode(_desc)) != keccak256(abi.encode("")));
        proposalIdToProposal[proposalCount] = Proposal(_desc, 0);
        emit ProposalRegistered(proposalCount);
        proposalCount++;
    }

    /** @notice end the proposal register period by the admin */
    function endProposalRegister() external onlyOwner {
        require(currentState == WorkflowStatus.ProposalsRegistrationStarted, "innapropriate time call");
        currentState = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, currentState);
    }

    /** @notice start the vote period by the admin*/
    function startVotingSession() external onlyOwner {
        require(currentState == WorkflowStatus.ProposalsRegistrationEnded, "innapropriate time call");
        currentState = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, currentState);
    }

    /** @notice Voter can deposit his vote on a proposal 
        @param _proposalId the ID of the proposal */
    function vote(uint _proposalId) external onlyRegistered {
        require(currentState == WorkflowStatus.VotingSessionStarted, "Voting session not opened");
        require(addressToVoter[msg.sender].hasVoted == false, "voter already voted");
        require(
            keccak256(abi.encode(proposalIdToProposal[_proposalId].description)) != keccak256(abi.encode("")),
            "incorrect proposalId: proposal doesn't exist"
        );

        proposalIdToProposal[_proposalId].voteCount++;
        addressToVoter[msg.sender].votedProposalId = _proposalId;
        addressToVoter[msg.sender].hasVoted == true;

        emit Voted(msg.sender, _proposalId);
    }

    /** @notice end the vote period by the admin */
    function endVoteSession() external onlyOwner {
        require(currentState == WorkflowStatus.VotingSessionStarted, "innapropriate time call");
        currentState = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, currentState);
    }

    /** @notice trigger by the admin the vote calculation and define the winner proposal */
    function VoteTalling() external onlyOwner {
        require(currentState == WorkflowStatus.VotingSessionEnded, "innapropriate time call");
        uint _winningProposalId;

        for(uint i = 1; i < proposalCount; i++){
            if(proposalIdToProposal[i].voteCount > proposalIdToProposal[_winningProposalId].voteCount){
                _winningProposalId = i;
            }
        }
        winningProposalId = _winningProposalId;
        currentState = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, currentState);
    }

    /** @notice Returns the informations about proposal winner  */
    function getWinner() external view returns(string memory description, uint voteCount){
        require(winningProposalId > 0, "no winner determined");
        return (proposalIdToProposal[winningProposalId].description, voteCount);
    }

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);
}