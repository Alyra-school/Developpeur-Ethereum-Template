## `Voting`





### `onlyVoters()`

verify if the sender address is registered as a voter




### `getVoter(address _addr) → struct Voting.Voter` (external)

* @notice Returns the voter object of the given address
        @param _addr the address of the voter */



### `getOneProposal(uint256 _id) → struct Voting.Proposal` (external)

* @notice Returns the proposal object of the given ID
        @param _id the id of the proposal */



### `getWinner() → struct Voting.Proposal` (external)

* @notice Returns the informations about proposal winner  */



### `addVoter(address _addr)` (public)

* @notice Admin can register a voter by calling this function
        @param _addr the address of the whitelisted voter */



### `addProposal(string _desc)` (external)

* @notice Voter can register a new proposal
        @param _desc the description of the proposal */



### `setVote(uint256 _id)` (external)

* @notice Voter can deposit his vote on a proposal 
        @param _id the ID of the proposal */



### `startProposalsRegistering()` (external)

end the whitelisting period of voters by the admin and start the registering proposals period */



### `endProposalsRegistering()` (external)

end the proposal register period by the admin */



### `startVotingSession()` (external)

start the vote period by the admin*/



### `endVotingSession()` (external)

end the vote period by the admin */



### `tallyVotes()` (external)

trigger by the admin the vote calculation and define the winner proposal */




### `VoterRegistered(address _voterAddress)`

emit when a new voter is registered by the admin
        @param _voterAddress the address of the registered voter



### `WorkflowStatusChange(enum Voting.WorkflowStatus _previousStatus, enum Voting.WorkflowStatus _newStatus)`

emit when the status is changing
        @param _previousStatus the status before the change
        @param _newStatus the status after the change



### `ProposalRegistered(uint256 _proposalId)`

emit when a new proposal is registered by a voter
        @param _proposalId the ID of the new proposal



### `Voted(address _voter, uint256 _proposalId)`

emit when a voter is voting 
        @param _voter the address of the voter who voted
        @param _proposalId the ID of the proposal which got voted




### `Voter`


bool isRegistered


bool hasVoted


uint256 votedProposalId


### `Proposal`


string description


uint256 voteCount



### `WorkflowStatus`




















