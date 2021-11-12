const { Voting, voter1, voter2, voter3, admin, testStateChange, getProposalsArray } = require('./utilsVoting');

const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract("voting.sol", accounts => {
    /** 'Voting' context include all the tests about the voting step */
    context("Voting", () => {
        /** Initial state: 
         * - contract is deployed by the admin address
         * - voter1, voter2 & voter3 are registered 
         * - 1 proposal is submitted by each registered voter 
         * - Proposal registration period ended */
         before(async () => {
            this.voting = await Voting.new({from: accounts[admin]});

            await this.voting.addVoter(accounts[voter1], {from: accounts[admin]});
            await this.voting.addVoter(accounts[voter2], {from: accounts[admin]});
            await this.voting.addVoter(accounts[voter3], {from: accounts[admin]});

            await this.voting.startProposalsRegistering({from: accounts[admin]})

            await this.voting.addProposal("Proposal of voter1", {from: accounts[voter1]});
            await this.voting.addProposal("Proposal of voter2", {from: accounts[voter2]});
            await this.voting.addProposal("Proposal of voter3", {from: accounts[voter3]});

            await this.voting.endProposalsRegistering({from: accounts[admin]});
        })

        context("state testing", () => {
            it("should try to vote and revert", async () => {
                await expectRevert(
                    this.voting.setVote(0, {from: accounts[voter1]}),
                    "Voting session havent started yet"
                )
            })
            it("should change the state to: VotingSessionStarted", async () => {
                await testStateChange(
                    Voting.WorkflowStatus.ProposalsRegistrationEnded,
                    Voting.WorkflowStatus.VotingSessionStarted,
                    this.voting,
                    this.voting.startVotingSession 
                )
            })
        })
        context("vote function testing", () => {
            it("should try to vote and revert", async () => {
                let possibleProposal = await getProposalsArray(this.voting);
                let possibleProposalIDs = possibleProposal.length - 1;

                //case where an ID proposal doesn't exist
                await expectRevert(
                    this.voting.setVote(possibleProposalIDs + 1, {from: accounts[voter1]}),
                    "revert"
                )
            })
            it("should vote from voter1 for Proposal of voter2", async () => {
                //"Proposal of voter2" is ID 1;
                let idToVote = 1;
                
                let receipt = await this.voting.setVote(1, {from: accounts[voter1]});
                let voter1Object = await this.voting.getVoter(accounts[voter1], {from: accounts[voter1]});
                let votedProposalObject = await this.voting.getOneProposal(idToVote);

                expect(votedProposalObject.description).to.be.equal("Proposal of voter2");
                expectEvent(
                    receipt,
                    'Voted',
                    {voter: accounts[voter1], proposalId: new BN(idToVote)}
                )
                expect(voter1Object.hasVoted).to.be.equal(true);
                expect(voter1Object.votedProposalId).to.be.equal(idToVote.toString());
                expect(votedProposalObject.voteCount).to.be.equal('1');
            })
            it("should change the state to: VotingSessionEnded", async () => {
                await testStateChange(
                    Voting.WorkflowStatus.VotingSessionStarted,
                    Voting.WorkflowStatus.VotingSessionEnded,
                    this.voting,
                    this.voting.endVotingSession
                )
            })
        })
    })
})