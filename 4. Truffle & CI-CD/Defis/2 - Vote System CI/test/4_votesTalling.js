const { Voting, voter1, voter2, voter3, admin } = require('./utilsVoting');

const { BN, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract("voting.sol", accounts => {
    /** 'Ending' context include all the tests about the talling of votes and checking step */
    context("Ending", () => {
        before(async () => {
            /** Initial state: 
            * - contract is deployed by the admin address
            * - voter1, voter2 & voter3 are registered 
            * - 1 proposal is submitted by each registered voter 
            * - each voters voted: voter1/voter3 -> Proposal of voter3, voter3 -> Proposal of voter1 */
            this.voting = await Voting.new({from: accounts[admin]});

            await this.voting.addVoter(accounts[voter1], {from: accounts[admin]});
            await this.voting.addVoter(accounts[voter2], {from: accounts[admin]});
            await this.voting.addVoter(accounts[voter3], {from: accounts[admin]});

            await this.voting.startProposalsRegistering({from: accounts[admin]})

            await this.voting.addProposal("Proposal of voter1", {from: accounts[voter1]});
            await this.voting.addProposal("Proposal of voter2", {from: accounts[voter2]});
            await this.voting.addProposal("Proposal of voter3", {from: accounts[voter3]});

            await this.voting.endProposalsRegistering({from: accounts[admin]});
            await this.voting.startVotingSession({from: accounts[admin]});

            await this.voting.setVote(2, {from: accounts[voter1]});
            await this.voting.setVote(2, {from: accounts[voter2]});
            await this.voting.setVote(0, {from: accounts[voter3]});

            await this.voting.endVotingSession({from: accounts[admin]});
        })
        context("tally votes testing", () => {
            it("should tally votes and return Proposal of voter3 as winner", async () => {
                let receipt = await this.voting.tallyVotes({from: accounts[admin]});
                let winningProposalObject = await this.voting.getWinner();

                expectEvent(
                    receipt,
                    'WorkflowStatusChange',
                    {_previousStatus: new BN(Voting.WorkflowStatus.VotingSessionEnded), _newStatus: new BN(Voting.WorkflowStatus.VotesTallied)}
                )
                expect(winningProposalObject.description).to.be.equal("Proposal of voter3");
                expect(winningProposalObject.voteCount).to.be.equal('2');
            })
        })
    })
})