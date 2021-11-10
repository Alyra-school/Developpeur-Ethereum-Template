/** 
 *  @description This file describe all the tests for the contract voting.sol
 *  @author Loïs L.
 */
const Voting = artifacts.require("Voting");

const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract(Voting, accounts => {
    const admin = accounts[0];
    const voter1 = accounts[1];
    const voter2 = accounts[2];
    const voter3 = accounts[3];

    /** 
     *  @description as our contract doesn't have any fonction to retrieve the proposals array,
     *  we need to do it manually by calling each elements of the array.
     *  @param voting The contract instance to get the datas from
     *  @returns an array containing all the called datas from the contract array
     */
    async function getProposalsArray(voting){
        let proposals = [];
        try{
            for(let i = 0; true; i++){
                let proposalObject = await voting.proposalsArray.call(i);
                proposals.push(proposalObject);
            } 
        }
        catch{
            return proposals;
        }
    }

    /** 'Voters registration' context include all tests about the voters registering step */
    context("Voters registration", () => {
        /** Initial state: 
         * - contract is deployed by the admin address
         * - nobody is whitelisted */
        before(async () => {
            this.voting = await Voting.new({from: admin});
        })

        it("should return state: RegisteringVoters", async () => {
            currentState = await this.voting.workflowStatus.call();
            expectedState = Voting.WorkflowStatus.RegisteringVoters;
            expect(currentState).to.be.bignumber.equal(new BN(expectedState));
        })
        it("should try to register from non-admin address and revert", async () => {
            /** case where someone non-admin want to whitelist himself */
            await expectRevert(
                this.voting.addVoter(voter1, {from: voter1}),
                "Ownable: caller is not the owner"
            );
        })
        it("should register voter1", async () => {
            let receipt = await this.voting.addVoter(voter1, {from: admin});

            expectEvent(receipt, 'VoterRegistered', {voterAddress: voter1});
        })
        it("should return that voter1 is registered", async () => {
            let voterObject = await this.voting.getVoter(voter1);

            expect(voterObject.isRegistered).to.equal(true);
        })
    })

    /** 'Proposal registration' context include all tests about the proposal registration step */
    context("Proposal registration", () => {
        /** Initial state: 
         * - contract is deployed by the admin address
         * - voter1 and voter2 are registered */
        before(async () => {
            this.voting = await Voting.new({from: admin});
            await this.voting.addVoter(voter1, {from: admin});
            await this.voting.addVoter(voter2, {from: admin});
        })

        it("should try to create a Proposal and revert", async () => {
            //case where a voter try to submit a proposal before it started
            let voter1Proposal = "My too early Proposal";

            await expectRevert(
                this.voting.addProposal(voter1Proposal, {from: voter1}),
                "Proposals are not allowed yet"
            );
        })
        /** as we already tested the same function in the 'Voters registration' context,
         *  we could skip it this time to save time on testing...*/
        it("should try to change state from non-admin address and revert", async () => {
            await expectRevert(
                this.voting.startProposalsRegistering({from: voter2}),
                "Ownable: caller is not the owner"
            );
        })
        it("should change the state to: ProposalsRegistrationStarted", async () => {
            let currentState = await this.voting.workflowStatus.call();
            const previousStatus = Voting.WorkflowStatus.RegisteringVoters;
            const expectedNewStatus = Voting.WorkflowStatus.ProposalsRegistrationStarted;

            //verifyng that the state 'previousStatus' to change is correct
            expect(currentState).to.be.bignumber.equal(new BN(previousStatus));

            //changing the state to the 'expectedNewStatus'
            let receipt = await this.voting.startProposalsRegistering({from: admin});
            currentState = await this.voting.workflowStatus.call();

            //verifyng that the current state 'currentState' is changed to the new state 'expectedNewStatus'
            expectEvent(
                receipt,
                'WorkflowStatusChange',
                {previousStatus: new BN(previousStatus), newStatus: new BN(expectedNewStatus)}
            );  
            expect(currentState).to.be.bignumber.equal(new BN(expectedNewStatus));
        })
        it("should try to create an empty Proposal and revert", async () => {
            let voter1Proposal = "";

            await expectRevert(
                this.voting.addProposal(voter1Proposal, {from: voter1}),
                "Vous ne pouvez pas ne rien proposer"
            );
        })
        it("should create a new Proposal: My first proposal", async () => {
            let voter1Proposal = "My first proposal";

            let receipt = await this.voting.addProposal(voter1Proposal, {from: voter1});
            let proposals = await getProposalsArray(this.voting);
            let newProposalID = proposals.length - 1;
            
            expectEvent(receipt, 'ProposalRegistered', {proposalId: new BN(newProposalID)});
        })
        it("should return the good proposal description", async () => {
            let proposals = await getProposalsArray(this.voting);
            let newProposalID = proposals.length - 1;

            let voter1ProposalObject = await this.voting.getOneProposal(newProposalID, {from: voter1});

            expect(voter1ProposalObject.description).to.be.equal("My first proposal");
        })
    })

    /** 'Voting' context include all the tests about the voting step */
    context("Voting", () => {
        //TODO
    })

    /** 'Ending' ccontext include all the tests about the talling of votes and checking step */
    context("Ending", () => {
        //TODO
    })
})
