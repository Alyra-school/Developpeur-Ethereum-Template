import React, { useState, useRef, useContext } from "react";

import { votingStatusContext, addressDataContext } from "./VotingMain";
import { providerContext } from "../App";

import "./OwnerPanel.css";

const OwnerPanel = () => {
    const votingStatus = useContext(votingStatusContext);
    const addressData = useContext(addressDataContext);
    const provider = useContext(providerContext);

    const [registeringMsg, setRegisteringMsg] = useState('');
    const inputAddress = useRef(null);

    const accounts = provider.accounts;
    const contract = provider.contract;

    const changeworkflowStatus = async (contractFn) => {
        try{
            await contractFn().send({from: accounts[0]});
        }
        catch(error){
            if(error.code === 4001){
                console.log("Error: owner rejected transaction");
            }
        }
    }

    if(!addressData.isOwner){
        return <></>
    }

    switch (votingStatus) {
        case '0':
            const inputIsAddress = (address) => {
                if(address.length === 42 && address.substring(0,2) === "0x"){
                    return true;
                } else return false;
            }

            const registerVoter = async () => {
                const addressToRegister = inputAddress.current.value;

                if(inputIsAddress(addressToRegister) === true){
                    try{
                        setRegisteringMsg("Waiting transaction to be confirmed...");
                        let receipt = await contract.methods.addVoter(addressToRegister).send({from: accounts[0]});
                        if(receipt){
                            setRegisteringMsg("Address succesfully registered !")
                        }
                    }
                    catch(error){
                        if(error.code === 4001){
                            setRegisteringMsg("Error: Transaction got denied by user");
                        }
                        else if(error.message.includes("Already registered")){
                            setRegisteringMsg("Error: This address is already registered");
                        }
        
                        console.log(error);
                    }
                } else setRegisteringMsg("Error: Wrong ethereum address format");
            }

            return (
                <>
                    <div className="status-title">
                        <h1>Voters Whitelisting</h1>
                    </div>
                    <div className='status-change-panel'>
                        <h2>Owner panel</h2>
                        <div className="registering-voter-panel">
                            <input className="register-voter" ref={inputAddress} maxLength='42'placeholder='Address to register'></input>
                            <button onClick={registerVoter}>Register</button>
                            <div className="registering-infos">
                            {registeringMsg}
                            </div>
                        </div>
                        <button onClick={changeworkflowStatus.bind(this, contract.methods.startProposalsRegistering)}>Start proposals registering</button>
                    </div>
                </>
            )
        case '1':
            return (
                <div className='status-change-panel'>
                    <h2>Owner panel</h2>
                    <button onClick={changeworkflowStatus.bind(this, contract.methods.endProposalsRegistering)}>End proposals registering</button>
                </div>
            )
        case '2':
            return (
                <div className='status-change-panel'>
                    <h2>Owner panel</h2>
                    <button onClick={changeworkflowStatus.bind(this, contract.methods.startVotingSession)}>Start voting session</button>
                </div>
            )
        case '3':
            return (
                <div className='status-change-panel'>
                    <h2>Owner panel</h2>
                    <button onClick={changeworkflowStatus.bind(this, contract.methods.endVotingSession)}>End voting session</button>
                </div>
            )
        case '4':
            return (
                <div className='status-change-panel'>
                    <h2>Owner panel</h2>
                    <button onClick={changeworkflowStatus.bind(this, contract.methods.tallyVotes)}>Tally votes / elect winner</button>
                </div>
            )
        default:
            return (
                <div className='status-change-panel'>
                    <h2>Owner panel</h2>
                    Error: cannot determinate state to change
                </div>
            )

    }
}

export default OwnerPanel;