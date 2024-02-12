// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting  is Ownable {

    // determiner fin du vote, trigger un compte des votes puis sort le gagant;

    mapping (address => bool)whitelistElecteurs;
    mapping (Proposal => uint)proposalId;

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
    Workflowstatus currentWorkflowStatus;


    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId); 
    event Voted (address voter, uint proposalId);

    Proposal[] public proposals;
    Voter[proposals[]] public arrayDesElecteurs;

    function addAddrToWhitelist(address _whitelistedAddress) external onlyOwner {
        require(!whitelistElecteurs[_whitelistedaddress], "This address is already whitelisted !");
        whitelistElecteurs[_whitelistedAddress] = true;
        emit VoterRegistered(_whitelistedAddress);
    }

    function changeWorkflowStatus(string _newStatus) external onlyOwner {
        require(_newStatus == WorflowStatus, "This is not a valid Worflow status");
        require(_newStatus != currentWorflowStatus, "This is already the current Workflow status");
        previousStatus = currentworkflowStatus;
        newStatus = _newStatus; 
        currentWorflowStatus = Workflowstatus._newStatus;
        emit WorkflowStatusChange(previousStatus, newStatus);
    }

    function submitProposal(string calldata _newProposal) external {
        require(whitelistElecteurs[msg.sender] ==  true, "You can't make a proposal since you're not whitelisted");
        require(currentWorkflowStatus = Workflowstatus.ProposalsRegistrationStarted, "Sorry. It's not the time for a proposal");
        Proposal memory newProposal = Proposal(_newProposal, voteCount);
        proposals.push(newProposal);
        if (proposals.lenght != 0) {
            emit Proposalregistred(proposals.lenght ++);
        } else emit Proposalregistred(1);
    }

    function vote(uint _proposalId) external {
        require(currentWorkflowStatus = Workflowstatus.VotingSessionStarted, "Sorry. It's not the time for voting");
        Proposal.voteCount ++; //revoir ce bout de code, comparer avec les autres fichiers sol 
        proposalId = _proposalId;
        emit Voted(msg.sender, proposalID);
    }

    function countVotes() external view onlyOwner returns(uint) {
        require(currentWorkflowStatus = Workflowstatus.VotingSessionEnded, "You can't count votes for now");
        proposals[Proposals[voteCount]];
    }

    function getVoteOf (address addr) external view returns(uint) {
        require(whitelistElecteurs[msg.sender] ==  true, "You can't access this information");
        return Voter.votedProposalId;
    }



    function getWinner() external view returns(string) {
        proposals.
        // return la propal avec le plus de voix
    }

    function detailsOfWinnerProposal() external view returns(string) {
        require(currentWorkflowStatus = Workflowstatus.VotesTallied, "There is no winner yet");
        // retunr la propal, nombre de voix et l'addr qui a proposé
    }

}
