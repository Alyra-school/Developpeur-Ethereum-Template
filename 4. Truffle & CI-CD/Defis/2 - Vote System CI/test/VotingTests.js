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


    /* ::::::::::::::: Utils Functions ::::::::::::::: */

    
    /** 
     *  @description as our contract doesn't have any fonction to retrieve the proposals array,
     *  we need to do it manually by calling each elements of the array.
     *  @param instance The contract instance to get the datas from
     *  @returns an array containing all the called datas from the contract array
     */
    async function getProposalsArray(instance){
        let proposals = [];
        try{
            for(let i = 0; true; i++){
                let proposalObject = await instance.proposalsArray.call(i);
                proposals.push(proposalObject);
            } 
        }
        catch{
            return proposals;
        }
    }

    /** 
     *  @description used to verify if a state is changing as expected
     *  @dev as we change the state multiples times during the use of the contract,
     *  this function avoid to write the same tests multiple times with just different states to test
     *  @param previousState the previous (current when called) state
     *  @param expectedNewState the new state, expected to be the new current one at the end of function
     *  @param instance the contract instance to get and set state
     *  @param stateChangeFn the function to use to set the new state
     */
    async function testStateChange(
        previousState,
        expectedNewState,
        instance,
        stateChangeFn
    ) {
        let currentState = await instance.workflowStatus.call();

        //verifyng that the state 'previousState' to change is correct
        expect(currentState).to.be.bignumber.equal(new BN(previousState));

        //changing the state to the 'expectedNewStatus'
        let receipt = await stateChangeFn({from: admin});
        currentState = await instance.workflowStatus.call();

        //verifyng that the current state 'currentState' is changed to the new state 'expectedNewStatus'
        expectEvent(
            receipt,
            'WorkflowStatusChange',
            {previousStatus: new BN(previousState), newStatus: new BN(expectedNewState)}
        );  
        expect(currentState).to.be.bignumber.equal(new BN(expectedNewState));
    }



    
    /* ::::::::::::::: TESTS :::::::::::::::  */




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
            let voterObject = await this.voting.getVoter(voter1, {from: voter1});

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

        context("state testing", () => {
            it("should try to create a Proposal and revert", async () => {
                //case where a voter try to submit a proposal before it started
                let voter1Proposal = "My too early Proposal";
    
                await expectRevert(
                    this.voting.addProposal(voter1Proposal, {from: voter1}),
                    "Proposals are not allowed yet"
                );
            })
            /** as we already tested the same function in the 'Voters registration' context,
             *  we could skip it this time and next time to save time on testing...*/
            it("should try to change state from non-admin address and revert", async () => {
                await expectRevert(
                    this.voting.startProposalsRegistering({from: voter2}),
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

    /** 'Voting' context include all the tests about the voting step */
    context("Voting", () => {
        /** Initial state: 
         * - contract is deployed by the admin address
         * - voter1, voter2 & voter3 are registered 
         * - 1 proposal is submitted by each registered voter 
         * - Proposal registration period ended */
         before(async () => {
            this.voting = await Voting.new({from: admin});

            await this.voting.addVoter(voter1, {from: admin});
            await this.voting.addVoter(voter2, {from: admin});
            await this.voting.addVoter(voter3, {from: admin});

            await this.voting.startProposalsRegistering({from: admin})

            await this.voting.addProposal("Proposal of voter1", {from: voter1});
            await this.voting.addProposal("Proposal of voter2", {from: voter2});
            await this.voting.addProposal("Proposal of voter3", {from: voter3});

            await this.voting.endProposalsRegistering({from: admin});
        })
        context("state testing", () => {
            it("should try to vote and revert", async () => {
                await expectRevert(
                    this.voting.setVote(0, {from: voter1}),
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
                    this.voting.setVote(possibleProposalIDs + 1, {from: voter1}),
                    "revert"
                )
            })
            it("should vote from voter1 for Proposal of voter2", async () => {
                //"Proposal of voter2" is ID 1;
                let idToVote = 1;
                
                let receipt = await this.voting.setVote(1, {from: voter1});
                let voter1Object = await this.voting.getVoter(voter1, {from: voter1});
                let votedProposalObject = await this.voting.getOneProposal(idToVote);

                expect(votedProposalObject.description).to.be.equal("Proposal of voter2");
                expectEvent(
                    receipt,
                    'Voted',
                    {voter: voter1, proposalId: new BN(idToVote)}
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

    /** 'Ending' context include all the tests about the talling of votes and checking step */
    context("Ending", () => {
        before(async () => {
            /** Initial state: 
         * - contract is deployed by the admin address
         * - voter1, voter2 & voter3 are registered 
         * - 1 proposal is submitted by each registered voter 
         * - each voters voted: voter1/voter3 -> Proposal of voter3, voter3 -> Proposal of voter1 */
            this.voting = await Voting.new({from: admin});

            await this.voting.addVoter(voter1, {from: admin});
            await this.voting.addVoter(voter2, {from: admin});
            await this.voting.addVoter(voter3, {from: admin});

            await this.voting.startProposalsRegistering({from: admin})

            await this.voting.addProposal("Proposal of voter1", {from: voter1});
            await this.voting.addProposal("Proposal of voter2", {from: voter2});
            await this.voting.addProposal("Proposal of voter3", {from: voter3});

            await this.voting.endProposalsRegistering({from: admin});
            await this.voting.startVotingSession({from: admin});

            await this.voting.setVote(2, {from: voter1});
            await this.voting.setVote(2, {from: voter2});
            await this.voting.setVote(0, {from: voter3});

            await this.voting.endVotingSession({from: admin});
        })
        context("tally votes testing", () => {
            it("should tally votes and return Proposal of voter3 as winner", async () => {
                let receipt = await this.voting.tallyVotes({from: admin});
                let winningProposalObject = await this.voting.getWinner();

                expectEvent(
                    receipt,
                    'WorkflowStatusChange',
                    {previousStatus: new BN(Voting.WorkflowStatus.VotingSessionEnded), newStatus: new BN(Voting.WorkflowStatus.VotesTallied)}
                )
                expect(winningProposalObject.description).to.be.equal("Proposal of voter3");
                expect(winningProposalObject.voteCount).to.be.equal('2');
            })
        })
    })
})
