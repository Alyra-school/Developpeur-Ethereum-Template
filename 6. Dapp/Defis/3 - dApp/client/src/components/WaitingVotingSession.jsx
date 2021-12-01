import React from "react";
import OwnerPanel from "./OwnerPanel";

import ProposalsList from "./ProposalsList";

const WaitingVotingSession = () => {

    return (
        <>
            <div className="status-title">
                <h1>Pre-voting</h1>
                <h2>The period of proposals registration is now finished.</h2>
                <h4>You'll be able to vote for your favorite proposal when the administrator will start the voting period.</h4>
                <h3>Please comeback later.</h3>
            </div>
            <OwnerPanel />
            <div className="main-listing">
                <h2>Registered proposals: </h2>
                <ProposalsList />
            </div>
        </>
    )
}

export default WaitingVotingSession;