import React, { useState, useContext } from "react";
import ProposalsList from "./ProposalsList";

import { providerContext } from "../App";

const Results = () => {
    const provider = useContext(providerContext);

    const contract = provider.contract;
    const [winner, setWinner] = useState(null);

    const getWinner = async () => {
        try{
            let _winner = await contract.methods.getWinner().call();
            if(_winner){
             setWinner(_winner);
            }
        }
        catch(error){
 
        }
    }

    const Winner = () => {
        if(winner){
            return (
                <h3 className="winner-description">
                    Winning proposal is: "{winner.description}" with {winner.voteCount} votes.
                </h3>
            )
        }
        else return <></>
    }

    getWinner();
    return (
        <>
            <div className="status-title">
                <h1>Results</h1>
            </div>
            <div className="results-winner">
                <Winner />
            </div>
            <ProposalsList />
        </>
    )
}

export default Results;