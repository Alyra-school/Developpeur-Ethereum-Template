import React, { useContext } from "react";
import OwnerPanel from "./OwnerPanel";

import ProposalsList from "./ProposalsList";
import { addressDataContext } from "./VotingMain";

const VotingSession = () => {
    const voter = useContext(addressDataContext);

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
            <OwnerPanel />
        </>
    )
}

export default VotingSession;