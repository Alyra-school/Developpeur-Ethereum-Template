// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable{
    event WhiteListed (address _address);
    event BlackListed (address _address);

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

    mapping (address => bool) private comptesWL;
    mapping (address => bool) private comptesBL;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    struct Proposal {
        string description;
        uint voteCount;
    }

    function whitelist(address _address) public onlyOwner{
        require(!comptesWL[_address],"deja WL");
        require(!comptesBL[_address],"deja BL");
        comptesWL[_address] = true;
        emit WhiteListed(_address);
    }

    function blacklist(address _address) public onlyOwner{
        require(!comptesBL[_address],"deja BL");
        require(!comptesWL[_address],"deja WL");
        comptesBL[_address] = false;
        emit BlackListed(_address);
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
