const voting = artifacts.require("Voting");
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

// Au minimum
// • Trois bons tests utilisant expect, expectRevert et expectEvent
// • les trois sur une fonction a minima
// • Ajouter un ReadMe, avec les details de vos coverage
// Pour améliorer le rendu
// • Utiliser des contextes intelligents
// • Couverture de test large (toutes les fonctionnalités avec plusieurs tests)
// • Faire du test unitaire: ne pas trop concatener

contract("Voting", accounts => {
    let votingInstance;

    const owner = accounts[0];
    const voter1 = accounts[1];
    const voter2 = accounts[2];
    const voter3 = accounts[3];

    describe("Getter", () => {
        beforeEach(async () => {
            votingInstance = await voting.new({ from: owner });
            await votingInstance.addVoter(voter1, { from: owner })
        });

        it("should voter is whitelisted", async () => {
            const storedData = await votingInstance.getVoter(voter1, { from: voter1 });
            expect(storedData.isRegistered).to.be.true;
        });

        it("should voter is not whitelisted", async () => {
            const storedData = await votingInstance.getVoter(voter2, { from: voter1 });
            expect(storedData.isRegistered).to.be.false;
        });

        it("should return proposal from id", async () => {
            await votingInstance.startProposalsRegistering({ from: owner });
            await votingInstance.addProposal("Premiere proposition", { from: voter1 });
            const storedData = await votingInstance.getOneProposal(0, { from: voter1 });
            // console.log(storedData);
            expect(storedData.description).to.equal("Premiere proposition");
            expect(new BN(storedData.voteCount)).to.be.bignumber.equal(new BN(0));
        });
    });

    // ::::::::::::: REGISTRATION ::::::::::::: //

    describe("Registration", () => {
        beforeEach(async () => {
            votingInstance = await voting.new({ from: owner });
        });

        it("Shouldn't be able to register, require session started", async () => {
            await votingInstance.startProposalsRegistering();
            await expectRevert(
                 votingInstance.addVoter(voter1, { from: owner }),
                'Voters registration is not open yet'
            );
        });

        it("Shouldn't be able to register a second time, require", async () => {
            await votingInstance.addVoter(voter1, { from: owner });
            await expectRevert(
                votingInstance.addVoter(voter1, { from: owner }),
               'Already registered'
           );
        });
    })

    // ::::::::::::: PROPOSAL ::::::::::::: // 

    describe("Proposal", () => {
        beforeEach(async () => {
            votingInstance = await voting.new({ from: owner });
            await votingInstance.addVoter(voter1, { from: owner });
        })

        // Require allowed
        it("Should fail if voting session is not started, require", async () => {
            await expectRevert(
                votingInstance.addProposal("test", { from: voter1 }),
                'Proposals are not allowed yet'
            );
        });

        // Require string proposal
        it("Should fail if proposal is empty, require", async () => {
            await votingInstance.startProposalsRegistering({ from: owner });
            await expectRevert(
                votingInstance.addProposal("", { from: voter1 }),
                'Vous ne pouvez pas ne rien proposer'
            );
        });

        it("Should return id 0 for first proposal, event", async () => {
            await votingInstance.startProposalsRegistering({ from: owner });
            expectEvent(
                await votingInstance.addProposal("Premiere proposition", { from: voter1 }),
                "ProposalRegistered",
                { proposalId: new BN(0) }
            );
        });
    });
    
    // ::::::::::::: VOTE ::::::::::::: //

    describe("Vote", () => {
        before(async () => {
            votingInstance = await voting.new({ from: owner });
            await votingInstance.addVoter(voter1, { from: owner });
        });

        it("Should voting session started", async () => {
            await expectRevert(
                votingInstance.setVote(0, { from: voter1 }),
                "Voting session havent started yet"
            );
        });

        it("Should vote and emit voter proposal id", async () => {
            await votingInstance.startProposalsRegistering({ from: owner });
            await votingInstance.addProposal("Proposition 1", { from: voter1 });
            await votingInstance.endProposalsRegistering({ from: owner });
            await votingInstance.startVotingSession({ from: owner });
            await expectEvent(
                await votingInstance.setVote(0, { from: voter1 }),
                "Voted",
                { voter: voter1, proposalId: new BN(0) }
            )
        });

        it("Should not already voted", async () => {
            await expectRevert(
                votingInstance.setVote(0, { from: voter1 }),
                "You have already voted"
            );
        });
    });

    // ::::::::::::: STATE ::::::::::::: //

    describe("State", async () => {
        before(async () => {
            votingInstance = await voting.new({ from: owner });
        });

        it("Should ownly owner can call this, require", async () => {
            await expectRevert(
                votingInstance.startProposalsRegistering({ from: voter1 }),
                "Ownable: caller is not the owner"
            );

            await expectRevert(
                votingInstance.endProposalsRegistering({ from: voter1 }),
                "Ownable: caller is not the owner"
            );

            await expectRevert(
                votingInstance.startVotingSession({ from: voter1 }),
                "Ownable: caller is not the owner"
            );

            await expectRevert(
                votingInstance.endVotingSession({ from: voter1 }),
                "Ownable: caller is not the owner"
            );
        });

        it("Should start proposal registering, emit", async () => {
            expectEvent(
                await votingInstance.startProposalsRegistering({ from: owner }),
                "WorkflowStatusChange",
                { previousStatus: new BN(0), newStatus: new BN(1) }
            );
        });

        it("Should end proposals registering, emit", async () => {
            expectEvent(
                await votingInstance.endProposalsRegistering({ from: owner }),
                "WorkflowStatusChange",
                { previousStatus: new BN(1), newStatus: new BN(2) }
            );
        });

        it("Should start voting session, emit", async () => {
            expectEvent(
                await votingInstance.startVotingSession({ from: owner }),
                "WorkflowStatusChange",
                { previousStatus: new BN(2), newStatus: new BN(3) }
            );
        });

        it("Should end voting session, emit", async () => {
            expectEvent(
                await votingInstance.endVotingSession({ from: owner }),
                "WorkflowStatusChange",
                { previousStatus: new BN(3), newStatus: new BN(4) }
            );
        });
    });
    
    // ::::::::::::: TALLY VOTES ::::::::::::: //

    describe.skip("Tally votes", async () => {
        beforeEach(async () => {
            votingInstance = await voting.new({ from: owner });
            await votingInstance.addVoter(voter1, { from: owner });
            await votingInstance.addVoter(voter2, { from: owner });
            await votingInstance.addVoter(voter3, { from: owner });
            
            await votingInstance.startProposalsRegistering({ from: owner });
            await votingInstance.addProposal("Proposal 1", { from: voter1 });
            await votingInstance.addProposal("Proposal 2", { from: voter2 });
            await votingInstance.addProposal("Proposal 3", { from: voter3 });
            await votingInstance.endProposalsRegistering({ from: owner });

            await votingInstance.startVotingSession({ from: owner });
            await votingInstance.setVote(0, { from: voter1 });
            await votingInstance.setVote(0, { from: voter2 });
            await votingInstance.setVote(2, { from: voter3 });
        });

        it("Should only owner can tally vote, require", async () => {
            await expectRevert(
                votingInstance.tallyVotes({ from: voter1 }),
                "Ownable: caller is not the owner"
            )
        });

        it("Should voting session endend, require", async () => {
            await expectRevert(
                votingInstance.tallyVotes({ from: owner }),
                "Current status is not voting session ended"
            )
        });
        
        it("Should winning proposal id is setted", async () => {
            await votingInstance.endVotingSession({ from: owner });
            await votingInstance.tallyVotes({ from: owner });
            const storedData = await votingInstance.winningProposalID.call();
            expect(new BN(storedData.words[0])).to.be.bignumber.equal(new BN(0));
        });

        it("Should update workflow status, emit", async () => {
            await votingInstance.endVotingSession({ from: owner });
            expectEvent(
                await votingInstance.tallyVotes({ from: owner }),
                "WorkflowStatusChange",
                { previousStatus: new BN(4), newStatus: new BN(5) }
            )
        });
    });
});
