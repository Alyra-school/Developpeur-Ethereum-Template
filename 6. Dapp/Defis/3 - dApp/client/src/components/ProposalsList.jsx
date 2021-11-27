import React, { useState, useEffect, useContext } from "react";

import { providerContext } from "../App";
import { addressDataContext, votingStatusContext } from "./VotingMain";

import "./ProposalsList.css";

const ProposalsList = (props) => {
    const provider = useContext(providerContext);
    const votingStatus = useContext(votingStatusContext);
    const voter = useContext(addressDataContext);

    const contract = provider.contract;
    const accounts = provider.accounts;

    const [proposalsData, setProposalsData] = useState([]);

    const AddProposalsInTable = () => {
        /**if we can vote, elements should be clickable and execute voting contract function */
        if(votingStatus === '3' && !voter.hasVoted){
            return (
                <table className="proposals-table">
                    <thead>
                        <tr>
                            <th colSpan="3">Description</th>
                        </tr>
                    </thead>
                        <tbody>{proposalsData.map((proposal) => (<tr className="tr-vote" onClick={voteForProposal.bind(this, proposal.id)} key={proposal.id}><td>{proposal.description}</td></tr>))}</tbody>
                </table>
            )
        }
        if(votingStatus === '5'){
            return (
                <table className="proposals-table">
                    <thead>
                        <tr>
                            <th colSpan="1">Description</th>
                            <th colSpan="1">Vote Count</th>
                        </tr>
                    </thead>
                        <tbody>{proposalsData.map((proposal) => (<tr key={proposal.id}><td>{proposal.description}</td><td>{proposal.voteCount}</td></tr>))}</tbody>
                </table>
            )
        }
        else {
            return (
                <table className="proposals-table">
                    <thead>
                        <tr>
                            <th colSpan="3">Description</th>
                        </tr>
                    </thead>

                    <tbody>{proposalsData.map((proposal) => (<tr key={proposal.id}><td>{proposal.description}</td></tr>))}</tbody>
                </table>
            )
        }
    }

    const voteForProposal = async (proposalId) => {
        try{
            let receipt = await contract.methods.setVote(proposalId).send({from: accounts[0]});
            if(receipt){

            }
        }
        catch(error){
            if(error.code === 4001){
                console.log("Error: Transaction got denied by user");
            }
        }
    }

    useEffect(() => {
        contract.events.ProposalRegistered(null, async (error, event) => {
            if(!error){
                const idProposal = event.returnValues._proposalId;
                const proposalObject = await contract.methods.getOneProposal(idProposal).call();
                proposalObject.id = idProposal;
                setProposalsData(proposalsData => [...proposalsData, proposalObject]);
            }
        });

        (async () => {
            //Get all the already registered proposals to render
            await contract.getPastEvents(
                'ProposalRegistered',
                {fromBlock: 0, toBlock: 'latest'},
                async (error, events) => {
                    if(!error){
                        events.map(async (proposal) => {
                            const idProposal = proposal.returnValues._proposalId;
                            const proposalObject = await contract.methods.getOneProposal(idProposal).call();
                            proposalObject.id = idProposal;
                            setProposalsData(proposalsData => [...proposalsData, proposalObject]);  
                        })
                    }
                });
            })()

        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [])


    return (
        <div className="all-proposals">
            <AddProposalsInTable />
        </div>
    )
}

export default ProposalsList;