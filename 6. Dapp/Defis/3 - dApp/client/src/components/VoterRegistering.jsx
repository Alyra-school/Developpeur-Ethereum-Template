import React, { useState, useEffect } from "react";
import OwnerPanel from "./OwnerPanel";

import "./VoterRegistering.css"

const VoterRegistering = (props) => {
    const contract = props.provider.contract;
    const [eventsData, setEventsData] = useState([]);

    useEffect(() => {
        //Get all the already registered address before the render
        (async () => {
            setEventsData(await contract.getPastEvents('VoterRegistered', {fromBlock: 0, toBlock: 'latest'}));
        })()

        //subscribe to the new events
        contract.events.VoterRegistered(null, (error, event) => {
            if(!error){
                setEventsData(eventsData => [...eventsData, event]);
            }
        });

        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [])

    //case where a non-owner address try to access voter registration
    if(!props.isOwner){
        return(
            <>
                <div className="status-title">
                    <h1>Voters Whitelisting</h1>
                </div>
                <div className="not-owner">
                    <h2>
                        Owner is registering participants, you would be able to register a proposal after the whitelisting period !
                    </h2>
                </div>
            </>
        )
    }

    //case where an owner address try to acces voter registration -> authorized
    return (
        <>
            <OwnerPanel />
            <div className="previous-register">
                <h3>Registered address:</h3>
                <h4><ul className="registered-list">{eventsData.map((event) => (<li className="registered-list-element"ckey={event.id}>{event.returnValues._voterAddress}</li>))}</ul></h4>
            </div>
        </>
    )
}

export default VoterRegistering;