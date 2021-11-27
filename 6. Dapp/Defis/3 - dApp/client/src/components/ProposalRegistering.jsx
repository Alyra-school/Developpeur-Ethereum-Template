import React, { useState, useRef, useContext } from "react";

import ProposalsList from "./ProposalsList";
import OwnerPanel from "./OwnerPanel";

import { providerContext } from "../App";

import "./ProposalRegistering.css";

const ProposalRegistering = () => {
    const provider = useContext(providerContext);
    const contract = provider.contract;
    const accounts = provider.accounts;

    const proposalInput = useRef("");
    const [registeringMsg, setRegisteringMsg] = useState('');
    
    const submitProposal = async () => {
        const proposalToSubmit = proposalInput.current.value;

        if(proposalToSubmit === ""){
            setRegisteringMsg("Error: The proposal can't be empty");
            return
        }

        try{
            setRegisteringMsg("Waiting transaction to be confirmed...");
            const receipt = await contract.methods.addProposal(proposalToSubmit).send({from: accounts[0]});
            if(receipt){
                setRegisteringMsg("Proposal succesfully registered, it should now appear in the proposals list !")
            }
        }
        catch(error){
            if(error.code === 4001){
                setRegisteringMsg("Error: Transaction got denied by user");
            }

            console.log(error);
        }
    }

    return (
        <>
            <div className="status-title">
                <h1>Proposals registering</h1>
            </div>
            <div className="registering-proposal-panel">
                <input ref={proposalInput} placeholder="Write your proposals here" maxLength='256'></input>
                <button onClick={submitProposal}>Submit</button>
                <div className="registering-infos">
                    {registeringMsg}
                </div>
            </div>
            <div className="owner-panel">
                <OwnerPanel />
            </div>
            <div className="main-listing">
                <h2>Already registered proposals: </h2>
                <ProposalsList contract={contract}/>
          </div>
        </>
    )
}

export default ProposalRegistering;