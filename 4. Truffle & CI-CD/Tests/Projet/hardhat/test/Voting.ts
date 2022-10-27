import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Voting__factory, Voting } from "../typechain-types";


describe("Voting", () => {
    
    let voting: Voting;
    let owner: SignerWithAddress;
    let notOwner: SignerWithAddress;
    let voter1: SignerWithAddress;
    let voter2: SignerWithAddress;
    let voter3: SignerWithAddress;
    let proposals = ["GENESIS", "prop1", "prop2", "prop3"];
    let emptyProposal = "";

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    beforeEach(async () => {
        const Voting = await ethers.getContractFactory("Voting") as Voting__factory;
        [owner, 
            voter1, 
            voter2, 
            voter3, 
            notOwner] = await ethers.getSigners();
        voting = await Voting.deploy();
        await voting.deployed();
    })

    describe("Initial state", () => {

        it("Should deploy contract",async () => {
            const contractAddress = voting.address;
            expect(contractAddress).to.be.properAddress;
        })

        it("Should be in RegisteringVoters workflow status", async () => {
            const workflowStatus = await voting.workflowStatus();
            expect(workflowStatus)
            .to.equal(
                WorkflowStatus.RegisteringVoters
            );
        });

        it("Should have winning proposal ID set to 0", async () => {
            const winningProposalID = await voting.winningProposalID();
            expect(winningProposalID).to.equal(0);
        });
    });

    describe("Registering Voters", () => {
        it("Should add a voter",async () => {
            const tx = await voting.addVoter(owner.address);
            expect(tx).to.emit(
                voting, 
                "VoterRegistered"
            )
            .withArgs(owner.address);
        })

        it("Should revert addVoter because not owner", async () => {
            await expect(
                voting.connect(notOwner)
                .addVoter(owner.address)
            )
            .to.be.revertedWith(
                "Ownable: caller is not the owner"
            )
        })
        
        it("Should get voter added", async () => {
            await voting.addVoter(owner.address);
            const voter = await voting.getVoter(owner.address);
            expect(voter.isRegistered).to.be.true;
        })

        it("Should revert getVoter because non voter", async () => {
            await expect(
                voting.getVoter(owner.address)
            )
            .to.be.revertedWith(
                "You're not a voter"
            );
        })        
    })

    describe("Registering Proposals", () => {
        it("Should start proposals registration", async () => {
            const tx = await voting.startProposalsRegistering();
            expect(tx).to.emit(voting, "WorkflowStatusChange").withArgs(
                WorkflowStatus.RegisteringVoters,
                WorkflowStatus.ProposalsRegistrationStarted
            );
            const workflowStatus = await voting.workflowStatus();
            expect(workflowStatus).to.equal(
                WorkflowStatus.ProposalsRegistrationStarted
            );
        })

        it("Should revert startProposalsRegistering because non in good workflow status", async () => {
            await voting.startProposalsRegistering();
            await expect(
                voting.startProposalsRegistering()
            )
                .to.be.revertedWith(
                    "Registering proposals cant be started now"
                );
        })

        it("Should revert startProposalsRegistering because not owner", async () => {
            await expect(
                voting.connect(notOwner)
                .startProposalsRegistering()
            )
            .to.be.revertedWith(
                "Ownable: caller is not the owner"
            )
        })

        it("Should has GENESYS at id 0", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            const proposal = await voting.getOneProposal(0);
            expect(proposal.description).to.equal(proposals[0]);
        })

        it("Should add a proposal",async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            const tx = await voting.addProposal(proposals[1]);
            expect(tx).to.emit(voting, "ProposalRegistered").withArgs(0);
        })

        it("Should revert addProposal because non voter", async () => {
            await expect(
                voting.addProposal(proposals[1])
            )
            .to.be.revertedWith(
                "You're not a voter"
            );
        })

        it("Should revert addProposal because not in good workflow status", async () => {
            await voting.addVoter(owner.address);
            await expect(
                voting.addProposal(proposals[1])
            )
            .to.be.revertedWith(
                "Proposals are not allowed yet"
            );
        })

        it("Should revert addProposal because empty", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await expect(
                voting.addProposal(emptyProposal)
            )
            .to.be.revertedWith(
                "Vous ne pouvez pas ne rien proposer"
            );
        })

        it("Should get Proposal", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            const proposal = await voting.getOneProposal(1);
            expect(proposal.description).to.equal(proposals[1]);
        })

        it("Should revert getOneProposal because non voter", async () => {
            await expect(
                voting.getOneProposal(0)
            )
            .to.be.revertedWith(
                "You're not a voter"
            );
        })

        it("Should end proposals registration", async () => {
            await voting.startProposalsRegistering();
            const tx = await voting.endProposalsRegistering();
            expect(tx).to.emit(voting, "WorkflowStatusChange").withArgs(
                WorkflowStatus.ProposalsRegistrationStarted,
                WorkflowStatus.ProposalsRegistrationEnded
            );
            const workflowStatus = await voting.workflowStatus();
            expect(workflowStatus).to.equal(
                WorkflowStatus.ProposalsRegistrationEnded
            );
        })

        it("Should revert endProposalsRegistering because non in good workflow status", async () => {
            await expect(
                voting.endProposalsRegistering()
            )
            .to.be.revertedWith(
                "Registering proposals havent started yet"
            );
        })

        it("Should revert endProposalsRegistering because not owner", async () => {
            await expect(
                voting.connect(notOwner)
                    .endProposalsRegistering()
            )
            .to.be.revertedWith(
                "Ownable: caller is not the owner"
            )
        })
        
    })

    describe("Voting session", () => {

        it("Shoul start voting session",async () => {
            await voting.startProposalsRegistering();
            await voting.endProposalsRegistering();
            const tx = await voting.startVotingSession();
            expect(tx).to.emit(voting, "WorkflowStatusChange").withArgs(
                WorkflowStatus.ProposalsRegistrationEnded,
                WorkflowStatus.VotingSessionStarted
            );
            const workflowStatus = await voting.workflowStatus();
            expect(workflowStatus).to.equal(
                WorkflowStatus.VotingSessionStarted
            );
        })

        it("Should revert startVotingSession because not owner", async () => {
            await expect(
                voting.connect(notOwner)
                    .startVotingSession()
            )
            .to.be.revertedWith(
                "Ownable: caller is not the owner"
            )
        })

        it("Should revert startVotingSession because non in good workflow status", async () => {
            await expect(
                voting.startVotingSession()
            )
            .to.be.revertedWith(
                "Registering proposals phase is not finished"
            );
        })

        it("Should set a vote", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await voting.endProposalsRegistering();
            await voting.startVotingSession()
            const tx = await voting.setVote(1);
            expect(tx).to.emit(voting, "VoterRegistered").withArgs(owner.address);
        })

        it("Should revert setVote because not in good workflow status", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await expect(
                voting.setVote(1)
            )
            .to.be.revertedWith(
                "Voting session havent started yet"
            );
        })

        it("Should revert setVote because already vote", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await voting.endProposalsRegistering();
            await voting.startVotingSession()
            await voting.setVote(1);
            await expect(
                voting.setVote(1)
            )
            .to.be.revertedWith(
                "You have already voted"
            );
        })

        it("Should revert setVote because proposal not found", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await voting.endProposalsRegistering();
            await voting.startVotingSession()
            await expect(
                voting.setVote(2)
            )
            .to.be.revertedWith(
                "Proposal not found"
            );
        })

        it("Should revert setVote because proposal non voter", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await voting.endProposalsRegistering();
            await voting.startVotingSession()
            await expect(
                voting.connect(voter1).setVote(1)
            )
            .to.be.revertedWith(
                "You're not a voter"
            );
        })

        it("Should set voter hasvoted to true", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
            let voter = await voting.getVoter(owner.address);
            expect(voter.hasVoted).is.false;
            await voting.setVote(1);
            voter = await voting.getVoter(owner.address);
            expect(voter.hasVoted).is.true;
        })

        it("Should set voter votedProposalId", async () => {
            await voting.addVoter(owner.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
            await voting.setVote(1);
            const voter = await voting.getVoter(owner.address);
            expect(voter.votedProposalId).is.equal(1);
        })

        it("Shoul end voting session", async () => {
            await voting.startProposalsRegistering();
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
            const tx = await voting.endVotingSession();
            expect(tx).to.emit(voting, "WorkflowStatusChange").withArgs(
                WorkflowStatus.VotingSessionStarted,
                WorkflowStatus.VotingSessionEnded
            );
            const workflowStatus = await voting.workflowStatus();
            expect(workflowStatus).to.equal(
                WorkflowStatus.VotingSessionEnded
            );
        })

        it("Should revert endVotingSession because non in good workflow status", async () => {
            await expect(
                voting.endVotingSession()
            )
            .to.be.revertedWith(
                "Voting session havent started yet"
            );
        })

        it("Should revert endVotingSession because not owner", async () => {
            await expect(
                voting.connect(notOwner)
                    .endVotingSession()
            )
            .to.be.revertedWith(
                "Ownable: caller is not the owner"
            )
        })

        it("Should have 3 vote for prop1, 1 vote for prop2 and 0 for prop3", async () => {
            await voting.addVoter(owner.address);
            await voting.addVoter(voter1.address);
            await voting.addVoter(voter2.address);
            await voting.addVoter(voter3.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await voting.connect(voter1).addProposal(proposals[2]);
            await voting.addProposal(proposals[3]);
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
            await voting.setVote(1);
            await voting.connect(voter1).setVote(1);
            await voting.connect(voter2).setVote(2);
            await voting.connect(voter3).setVote(1);
            const proposal1 = await voting.getOneProposal(1);
            expect(proposal1.voteCount).to.equal(3);
            const proposal2 = await voting.getOneProposal(2);
            expect(proposal2.voteCount).to.equal(1);
            const proposal3 = await voting.getOneProposal(3);
            expect(proposal3.voteCount).to.equal(0);
        })
        
    })

    describe("Vote tallied", () => {
        it("Should tally votes",async () => {
            await voting.startProposalsRegistering();
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
            await voting.endVotingSession();
            const tx = await voting.tallyVotes();
            expect(tx).to.emit(voting, "WorkflowStatusChange").withArgs(
                WorkflowStatus.VotingSessionEnded,
                WorkflowStatus.VotesTallied
            );
            const workflowStatus = await voting.workflowStatus();
            expect(workflowStatus).to.equal(
                WorkflowStatus.VotesTallied
            );
        })

        it("Should revert tallyVotes because not owner", async () => {
            await expect(
                voting.connect(notOwner)
                    .tallyVotes()
            )
            .to.be.revertedWith(
                "Ownable: caller is not the owner"
            )
        })

        it("Should revert tallyVotes because non in good workflow status", async () => {
            await expect(
                voting.tallyVotes()
            )
            .to.be.revertedWith(
                "Current status is not voting session ended"
            );
        })

        it("Should tally votes", async () => {
            await voting.startProposalsRegistering();
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
            await voting.endVotingSession();
            const tx = await voting.tallyVotes();
            expect(tx).to.emit(voting, "WorkflowStatusChange").withArgs(
                WorkflowStatus.VotingSessionEnded,
                WorkflowStatus.VotesTallied
            );
            const workflowStatus = await voting.workflowStatus();
            expect(workflowStatus).to.equal(
                WorkflowStatus.VotesTallied
            );
        })

        it("Should get proposal 1 winning", async () => {
            await voting.addVoter(owner.address);
            await voting.addVoter(voter1.address);
            await voting.addVoter(voter2.address);
            await voting.addVoter(voter3.address);
            await voting.startProposalsRegistering();
            await voting.addProposal(proposals[1]);
            await voting.connect(voter1).addProposal(proposals[2]);
            await voting.addProposal(proposals[3]);
            await voting.endProposalsRegistering();
            await voting.startVotingSession();
            await voting.setVote(1);
            await voting.connect(voter1).setVote(1);
            await voting.connect(voter2).setVote(2);
            await voting.connect(voter3).setVote(1);
            await voting.endVotingSession();
            await voting.tallyVotes();
            const winningProposalID = await voting.winningProposalID();
            expect(winningProposalID).to.equal(1);
        })
        
    })

});
