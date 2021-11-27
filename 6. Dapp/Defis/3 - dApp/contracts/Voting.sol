// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

/** @title A whitelisting voting contract
    @notice This contract offer a voting system with: 
            - an admin, the contract owner
            - voters, with registered address by the admin
            Voters can first submit differents proposal about a topic.
            In a second time, Voters can vote one time for their favorite proposal 
            The proposal with the most votes will be the adopted solution 
    @author Cyril C. */
contract Voting is Ownable {

    // arrays for draw, uint for single
    // uint[] winningProposalsID;
    Proposal[] winningProposals;

    /** @notice Store the ID of the most voted proposal 
        @dev will be 0 before 'VoteTailling()' call */
    uint winningProposalID;
    
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
    enum  WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    /** @notice Define the current state of the Voting */
    WorkflowStatus public workflowStatus;
    Proposal[] public proposalsArray;

    /** @notice Index a 'Voter' to his address */
    mapping (address => Voter) private voters;

    /** @notice emit when a new voter is registered by the admin
        @param _voterAddress the address of the registered voter */
    event VoterRegistered(address _voterAddress);
    /** @notice emit when the status is changing
        @param _previousStatus the status before the change
        @param _newStatus the status after the change */
    event WorkflowStatusChange(WorkflowStatus _previousStatus, WorkflowStatus _newStatus);
    /** @notice emit when a new proposal is registered by a voter
        @param _proposalId the ID of the new proposal */
    event ProposalRegistered(uint _proposalId);
    /** @notice emit when a voter is voting 
        @param _voter the address of the voter who voted
        @param _proposalId the ID of the proposal which got voted */
    event Voted (address _voter, uint _proposalId);


    /** @notice verify if the sender address is registered as a voter */
    modifier onlyVoters() {
        require(voters[msg.sender].isRegistered, "You're not a voter/owner");
        _;
    }
    
    // on peut faire un modifier pour les états

    // ::::::::::::: GETTERS ::::::::::::: //

    /** @notice Returns the voter object of the given address
        @param _addr the address of the voter */
    function getVoter(address _addr) external onlyVoters view returns (Voter memory) {
        return voters[_addr];
    }

    /** @notice Returns the proposal object of the given ID
        @param _id the id of the proposal */
    function getOneProposal(uint _id) external view returns (Proposal memory) {
        return proposalsArray[_id];
    }

    /**
    function getWinners() external view returns (Proposal[] memory) {
        require(workflowStatus == WorkflowStatus.VotesTallied, 'Votes are not tallied yet');
        return winningProposals;
    }
    */

    /** @notice Returns the informations about proposal winner  */
    function getWinner() external view returns (Proposal memory) {
        require(workflowStatus == WorkflowStatus.VotesTallied, 'Votes are not tallied yet');
        return proposalsArray[winningProposalID];
    }
 
    // ::::::::::::: REGISTRATION ::::::::::::: // 

    /** @notice Admin can register a voter by calling this function
        @param _addr the address of the whitelisted voter */
    function addVoter(address _addr) public onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');
        require(voters[_addr].isRegistered != true, 'Already registered');
    
        voters[_addr].isRegistered = true;
        emit VoterRegistered(_addr);
    }
 
    /* facultatif
     * function deleteVoter(address _addr) external onlyOwner {
     *   require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Voters registration is not open yet');
     *   require(voters[_addr].isRegistered == true, 'Not registered.');
     *   voters[_addr].isRegistered = false;
     *  emit VoterRegistered(_addr);
    }*/

    // ::::::::::::: PROPOSAL ::::::::::::: // 

    /** @notice Voter can register a new proposal
        @param _desc the description of the proposal */
    function addProposal(string memory _desc) external onlyVoters {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, 'Proposals are not allowed yet');
        require(keccak256(abi.encode(_desc)) != keccak256(abi.encode("")), 'Vous ne pouvez pas ne rien proposer'); // facultatif
        // voir que desc est different des autres

        Proposal memory proposal;
        proposal.description = _desc;
        proposalsArray.push(proposal);
        emit ProposalRegistered(proposalsArray.length-1);
    }

    // ::::::::::::: VOTE ::::::::::::: //

    /** @notice Voter can deposit his vote on a proposal 
        @param _id the ID of the proposal */
    function setVote( uint _id) external onlyVoters {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        require(voters[msg.sender].hasVoted != true, 'You have already voted');
        require(_id <= proposalsArray.length, 'Proposal not found'); // pas obligé, et pas besoin du >0 car uint

        voters[msg.sender].votedProposalId = _id;
        voters[msg.sender].hasVoted = true;
        proposalsArray[_id].voteCount++;

        emit Voted(msg.sender, _id);
    }

    // ::::::::::::: STATE ::::::::::::: //

    /* on pourrait factoriser tout ça: par exemple:
    *  function setWorkflowStatus(WorkflowStatus _num) public onlyOwner {
    *    WorkflowStatus pnum = workflowStatus;
    *    workflowStatus = _num;
    *    emit WorkflowStatusChange(pnum, workflowStatus);
        } */ 

    /** @notice end the whitelisting period of voters by the admin and start the registering proposals period */
    function startProposalsRegistering() external onlyOwner {
        require(workflowStatus == WorkflowStatus.RegisteringVoters, 'Registering proposals cant be started now');
        workflowStatus = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    /** @notice end the proposal register period by the admin */
    function endProposalsRegistering() external onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationStarted, 'Registering proposals havent started yet');
        workflowStatus = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    /** @notice start the vote period by the admin*/
    function startVotingSession() external onlyOwner {
        require(workflowStatus == WorkflowStatus.ProposalsRegistrationEnded, 'Registering proposals phase is not finished');
        workflowStatus = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    /** @notice end the vote period by the admin */
    function endVotingSession() external onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionStarted, 'Voting session havent started yet');
        workflowStatus = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    /**
    function tallyVotesDraw() external onlyOwner {
       require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
        uint highestCount;
        uint[5]memory winners; // egalite entre 5 personnes max
        uint nbWinners;
        for (uint i = 0; i < proposalsArray.length; i++) {
            if (proposalsArray[i].voteCount == highestCount) {
                winners[nbWinners]=i;
                nbWinners++;
            }
            if (proposalsArray[i].voteCount > highestCount) {
                delete winners;
                winners[0]= i;
                highestCount = proposalsArray[i].voteCount;
                nbWinners=1;
            }
        }
        for(uint j=0;j<nbWinners;j++){
            winningProposalsID.push(winners[j]);
            winningProposals.push(proposalsArray[winners[j]]);
        }
        workflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }
    */

    /** @notice trigger by the admin the vote calculation and define the winner proposal */
    function tallyVotes() external onlyOwner {
        require(workflowStatus == WorkflowStatus.VotingSessionEnded, "Current status is not voting session ended");
        uint _winningProposalId;
        for (uint256 p = 0; p < proposalsArray.length; p++) {
            if (proposalsArray[p].voteCount > proposalsArray[_winningProposalId].voteCount) {
                _winningProposalId = p;
            }
        }

        winningProposalID = _winningProposalId;

        workflowStatus = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }
}