import React from "react";

import OwnerPanel from "./OwnerPanel";
import ProposalsList from "./ProposalsList";

const WaitingResults = () => {

    return (
        <>
            <div className="status-title">
                <h1>Waiting results...</h1>
            </div>
            <h3 className="waiting-results-msg">
                The voting period has ended and results will now be soon tallied, please comeback later.
            </h3>
            <OwnerPanel />
            <ProposalsList />
        </>
    )
}

export default WaitingResults;