const { Voting, voter1, voter2, admin, testStateChange, getProposalsArray } = require('./utilsVoting');

const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract("voting.sol", accounts => {

    /** 'Proposal registration' context include all tests about the proposal registration step */
    context("Proposal registration", () => {
        /** Initial state: 
         * - contract is deployed by the admin address
         * - voter1 and voter2 are registered */
        before(async () => {
            this.voting = await Voting.new({from: accounts[admin]});

            await this.voting.addVoter(accounts[voter1], {from: accounts[admin]});
            await this.voting.addVoter(accounts[voter2], {from: accounts[admin]});
        })

        context("state testing", () => {
            it("should try to create a Proposal and revert", async () => {
                //case where a voter try to submit a proposal before it started
                let voter1Proposal = "My too early Proposal";
    
                await expectRevert(
                    this.voting.addProposal(voter1Proposal, {from: accounts[voter1]}),
                    "Proposals are not allowed yet"
                );
            })
            /** as we already tested the same function in the 'Voters registration' context,
             *  we could skip it this time and next time to save time on testing...*/
            it("should try to change state from non-admin address and revert", async () => {
                await expectRevert(
                    this.voting.startProposalsRegistering({from: accounts[voter2]}),
                    "Ownable: caller is not the owner"
                );
            })
            it("should change the state to: ProposalsRegistrationStarted", async () => {
                await testStateChange(
                    Voting.WorkflowStatus.RegisteringVoters,
                    Voting.WorkflowStatus.ProposalsRegistrationStarted,
                    this.voting,
                    this.voting.startProposalsRegistering
                    )
            })
        })
        context("register proposals function testing", () => {
            it("should try to create an empty Proposal and revert", async () => {
                let voter1Proposal = "";
    
                await expectRevert(
                    this.voting.addProposal(voter1Proposal, {from: accounts[voter1]}),
                    "Vous ne pouvez pas ne rien proposer"
                );
            })
            it("should create a new Proposal: My first proposal", async () => {
                let voter1Proposal = "My first proposal";
    
                let receipt = await this.voting.addProposal(voter1Proposal, {from: accounts[voter1]});
                let proposals = await getProposalsArray(this.voting);
                let newProposalID = proposals.length - 1;
                
                expectEvent(receipt, 'ProposalRegistered', {proposalId: new BN(newProposalID)});
            })
            it("should return the good proposal description", async () => {
                let proposals = await getProposalsArray(this.voting);
                let newProposalID = proposals.length - 1;
    
                let voter1ProposalObject = await this.voting.getOneProposal(newProposalID);
    
                expect(voter1ProposalObject.description).to.be.equal("My first proposal");
            })
            it("should change the state to: ProposalsRegistrationEnded", async () => {
                await testStateChange(
                    Voting.WorkflowStatus.ProposalsRegistrationStarted,
                    Voting.WorkflowStatus.ProposalsRegistrationEnded,
                    this.voting,
                    this.voting.endProposalsRegistering 
                )
            })
        })
    })
})