// contracts/Voting.sol
// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {
    uint256 private totalProposals = 0;
    uint256 public winningProposalId;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
    }
    struct Proposal {
        string description;
        uint256 voteCount;
    }
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus status = WorkflowStatus.RegisteringVoters;    

    mapping(uint256 => Proposal) private _proposals;
    mapping(address => Voter) private _voterWhitelist;

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(
        WorkflowStatus previousStatus,
        WorkflowStatus newStatus
    );
    event ProposalRegistered(uint256 proposalId);
    event Voted(address voter, uint256 proposalId);

    modifier isStatus(WorkflowStatus _status) {
        require(status == _status);
        _;
    }

    modifier isVoter(address _address) {
        require(
            _voterWhitelist[_address].isRegistered == true,
            "It's not a registered voter!"
        );
        _;
    }

    function nextStatus() internal view returns (WorkflowStatus) {
        return WorkflowStatus(uint256(status) + 1);
    }

    function changeStatus() public onlyOwner {
        require(uint256(status) <= 5, "Voting completed!");
        emit WorkflowStatusChange(status, nextStatus());
        status = nextStatus();
    }

    function registerVoter(address _address)
        public
        onlyOwner
        isStatus(WorkflowStatus.RegisteringVoters)
    {
        require(
            _voterWhitelist[_address].isRegistered == false,
            "Voter is already registered"
        );
        _voterWhitelist[_address] = Voter(true, false, 0);
        emit VoterRegistered(_address);
    }

    function endVoterRegistration()
        public
        onlyOwner
        isStatus(WorkflowStatus.RegisteringVoters)
    {
        changeStatus();
    }

    function addProposal(string memory _name)
        public
        isVoter(msg.sender)
        isStatus(WorkflowStatus.ProposalsRegistrationStarted)
    {
        require(keccak256(abi.encode(_name)) != keccak256(abi.encode("")));
        _proposals[totalProposals] = Proposal(_name, 0);
        emit ProposalRegistered(totalProposals);
        ++totalProposals;
    }

    function endProposalRegistration()
        public
        onlyOwner
        isStatus(WorkflowStatus.ProposalsRegistrationStarted)
    {
        changeStatus();
    }

    function startVoting()
        public
        onlyOwner
        isStatus(WorkflowStatus.ProposalsRegistrationEnded)
    {
        changeStatus();
    }

    function vote(uint256 _proposalId)
        public
        isVoter(msg.sender)
        isStatus(WorkflowStatus.VotingSessionStarted)
    {
        require(
            !_voterWhitelist[msg.sender].hasVoted,
            "You have already voted"
        );

        require(_proposalId > 0 && _proposalId <= totalProposals);

        // record vote
        _voterWhitelist[msg.sender].hasVoted = true;
        _voterWhitelist[msg.sender].votedProposalId = _proposalId;

        // update candidate vote number
        _proposals[_proposalId].voteCount++;

        // voted event
        emit Voted(msg.sender, _proposalId);
    }

    function endVoting()
        public
        onlyOwner
        isStatus(WorkflowStatus.VotingSessionStarted)
    {
        changeStatus();
    }

    function tallingVotes() public onlyOwner isStatus(WorkflowStatus.VotingSessionStarted){
        require(totalProposals > 0, "No proposals");
        uint256 winningVoteCount = 0;
        uint _winningProposalId;

        for (uint256 p = 0; p < totalProposals; p++) {
            if (_proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = _proposals[p].voteCount;
                _winningProposalId = p;
            }
        }
        winningProposalId = _winningProposalId;
        changeStatus();
    }

    function getWinner()
        external
        view
        isStatus(WorkflowStatus.VotesTallied)
        returns (string memory winnerDescription_, uint voteNumber_)
    {
        require(winningProposalId > 0, "Winner not found");
        winnerDescription_ = _proposals[winningProposalId].description;
        voteNumber_ = _proposals[winningProposalId].voteCount;
    }
}
