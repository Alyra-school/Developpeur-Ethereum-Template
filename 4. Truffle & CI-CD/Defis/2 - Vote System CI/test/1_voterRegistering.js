const { Voting, voter1, admin } = require('./utilsVoting');

const { BN, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

contract("voting.sol", accounts => {

    /** 'Voters registration' context include all tests about the voters registering step */
    context("Voters registration", () => {
        /** Initial state: 
         * - contract is deployed by the admin address
         * - nobody is whitelisted */
        before(async () => {
            this.voting = await Voting.new({from: accounts[admin]});
        })

        it("should return state: RegisteringVoters", async () => {
            currentState = await this.voting.workflowStatus.call();
            expectedState = Voting.WorkflowStatus.RegisteringVoters;
            expect(currentState).to.be.bignumber.equal(new BN(expectedState));
        })
        it("should try to register from non-admin address and revert", async () => {
            /** case where someone non-admin want to whitelist himself */
            await expectRevert(
                this.voting.addVoter(accounts[voter1], {from: accounts[voter1]}),
                "Ownable: caller is not the owner"
            );
        })
        it("should register voter1", async () => {
            let receipt = await this.voting.addVoter(accounts[voter1], {from: accounts[admin]});

            expectEvent(receipt, 'VoterRegistered', {voterAddress: accounts[voter1]});
        })
        it("should return that voter1 is registered", async () => {
            let voterObject = await this.voting.getVoter(accounts[voter1], {from: accounts[voter1]});

            expect(voterObject.isRegistered).to.equal(true);
        })
    })
})