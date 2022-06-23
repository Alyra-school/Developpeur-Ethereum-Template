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

    describe("Events tests", () => {
        // Un voter est ajouté à la liste et proposal started est activé
        beforeEach(async () => {
            votingInstance = await voting.new({ from: owner });
            await votingInstance.addVoter(voter1, { from: owner });
            await votingInstance.startProposalsRegistering({ from: owner });
        });

        
    })

    describe("Require tests", () => {
        beforeEach(async () => {
            votingInstance = await voting.new({ from: owner });
            await votingInstance.addVoter(voter1, { from: owner });
            // await votingInstance.startProposalsRegistering({ from: owner });
        });
    });

    describe("Proposal tests", () => {
        beforeEach(async () => {
            votingInstance = await voting.new({ from: owner });
            await votingInstance.addVoter(voter1, { from: owner });
        })

        // Require allowed
        it("Fail if voting session is not started", async () => {
            await expectRevert(
                votingInstance.addProposal("test", { from: voter1 }),
                'Proposals are not allowed yet'
            );
        });

        // Require string proposal
        it("Fail if proposal is empty", async () => {
            await votingInstance.startProposalsRegistering({ from: owner });
            await expectRevert(
                votingInstance.addProposal("", { from: voter1 }),
                'Vous ne pouvez pas ne rien proposer'
            );
        });

        // Emit proposal registered
        it("should return id 0 for first proposal", async () => {
            await votingInstance.startProposalsRegistering({ from: owner });
            await expectEvent(
                await votingInstance.addProposal("Premiere proposition", { from: voter1 }),
                "ProposalRegistered",
                { proposalId: new BN(0) }
            );
        });
    });
});
