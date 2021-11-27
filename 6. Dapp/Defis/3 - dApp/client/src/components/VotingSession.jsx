import React, { useState, useEffect, useContext } from "react";
import OwnerPanel from "./OwnerPanel";

import ProposalsList from "./ProposalsList";
import { providerContext } from "../App";
import { addressDataContext } from "./VotingMain";

const VotingSession = () => {
    const provider = useContext(providerContext);
    const voter = useContext(addressDataContext);

    const contract = provider.contract;
    const [registeringMsg, setRegisteringMsg] = useState("");

    useEffect(() => {
        contract.events.Voted(null, async (error, event) => {
            if(!error){
                const idProposal = event.returnValues._proposalId;
                const proposalObject = await contract.methods.getOneProposal(idProposal).call();
                setRegisteringMsg("You succesfully voted for \"" + proposalObject.description + "\"");
            }
        });
    })

    if(voter.hasVoted){
        return (
        <>
            <div className="status-title">
                <h1>Proposal voting</h1>
            </div>
            <h3 className="already-voted">You already voted, please comeback later for results.</h3>  
            <OwnerPanel />
            <div className="main-listing">
                <h2> Registered proposals: </h2>
                <ProposalsList />
            </div>         
        </>
        )
    }

    return (
        <>
            <div className="status-title">
                <h1>Proposal voting</h1>
            </div>
            <div className="main-listing">
                <h2>Vote for your favorite proposal: </h2>
                <ProposalsList />
            </div>
            <div className="registering-infos">
                {registeringMsg}
            </div>
            <OwnerPanel />
        </>
    )
}

export default VotingSession;