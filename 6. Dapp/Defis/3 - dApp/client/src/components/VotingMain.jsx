import React, { useState, useEffect, useContext, createContext } from "react";

import VoterRegistering from "./VoterRegistering";
import ProposalRegistering from "./ProposalRegistering";
import VotingSession from "./VotingSession";
import WaitingVotingSession from "./WaitingVotingSession";
import WaitingResults from "./WaitingResults";
import Results from "./Results";

import { providerContext } from "../App";


export const votingStatusContext = createContext(null);
export const addressDataContext = createContext({isRegistered: false, hasVoted: false, isOwner: false});

function VotingMain(){
  const provider = useContext(providerContext);
  const [addressData, setAddressData] = useState({isRegistered: false, hasVoted: false, isOwner: false});
  const [votingStatus, setVotingStatus] = useState(null);


  useEffect(() => {
    const retrieveVotingStatus = async () => {
        await provider.contract.methods.workflowStatus().call().then((result) => {setVotingStatus(result)});
      }

    const addressCheck = async () => {
        try{
          const voterObject = await provider.contract.methods.getVoter(provider.accounts[0]).call({from: provider.accounts[0]});
          setAddressData({...voterObject, isOwner: await ownerCheck()});
        }
        catch(error){
          if(error){
            setAddressData({isRegistered: false, isOwner: await ownerCheck()});
          }
        }
    }
    
    const ownerCheck = async () => {
        const ownerAddress = await provider.contract.methods.owner().call();
        
        if(ownerAddress.toLowerCase() === provider.accounts[0].toLowerCase()){
          return true;
        }
        else return false;
    }

    if(provider.contract){
      retrieveVotingStatus();
      addressCheck();

      provider.contract.events.WorkflowStatusChange(
        null,
        (error, event) => {
          if(!error){
            setVotingStatus(event.returnValues._newStatus)
          }
          else console.log(error);
      })
    } 
  }, [provider])
  
  console.log(addressData);
  if(!addressData.isRegistered && !addressData.isOwner) {
    return (
    <div className="not-registered">
      Only registered voters can access the voting session
    </div>
    )
  }

  switch (votingStatus) {
    case '0':
        return (
          <div className="main-voter-registering"> 
            <votingStatusContext.Provider value={votingStatus}>
                <providerContext.Provider value={provider}>
                    <addressDataContext.Provider value={addressData}>          
                        <VoterRegistering provider={provider} isOwner={addressData.isOwner}/>
                    </addressDataContext.Provider>
                </providerContext.Provider>
            </votingStatusContext.Provider>
          </div>
        )
    case '1':
      return (
        <>
          <div className="main-proposal-registering">
          <votingStatusContext.Provider value={votingStatus}>
                <addressDataContext.Provider value={addressData}>
                    <ProposalRegistering provider={provider} voter={addressData} />
                </addressDataContext.Provider>
            </votingStatusContext.Provider>
          </div>
        </>
      )
    case '2': 
    return (
        <>
          {/**<Nav />*/}
          <div className="main-waiting-voting-session">
            <votingStatusContext.Provider value={votingStatus}>
                <addressDataContext.Provider value={addressData}>
                    <WaitingVotingSession provider={provider} isOwner={addressData.isOwner} />
                </addressDataContext.Provider>
            </votingStatusContext.Provider>
          </div>
        </>
      )
    case '3': 
      return (
        <>
          {/**<Nav />*/}
          <div className="main-voting-session">
            <votingStatusContext.Provider value={votingStatus}>
                <addressDataContext.Provider value={addressData}>
                    <VotingSession />
                </addressDataContext.Provider>
            </votingStatusContext.Provider>
          </div>
        </>
      )
    case '4':
      return (
        <>
          <div className="main-waiting-results-session">
            <votingStatusContext.Provider value={votingStatus}>
                <addressDataContext.Provider value={addressData}>
                    <WaitingResults />
                </addressDataContext.Provider>
            </votingStatusContext.Provider>
          </div>
        </>
      )
    case '5':
        return (
            <div className="main-results">
                <votingStatusContext.Provider value={votingStatus}>
                  <Results />
                </votingStatusContext.Provider>
            </div>
        )
    case null:
      return (
        <div className="main-contract-waiting">
          Please wait while we retrieve the voting status...
        </div>
      )
    default:
      return (
        <div className="main-contract-error">
          Error during retrieving contract state !
        </div>
      )
  }
}

export default VotingMain;