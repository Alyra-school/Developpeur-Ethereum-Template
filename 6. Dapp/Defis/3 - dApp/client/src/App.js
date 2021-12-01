import React, { useState, useEffect, createContext } from "react";
import VotingContract from "./contracts/Voting.json";
import Web3 from "web3";

import "./App.css";
import VotingMain from "./components/VotingMain";

export const providerContext = createContext({web3: null, accounts: null, contract: null});

function App(){
  const [provider, setProvider] = useState({accounts: null, contract: null});

  const initWeb3 = async () => {
    try {
      (async () => {
        // Modern dapp browsers...
        if (window.ethereum) {
          const web3 = new Web3(window.ethereum);
          
          try {
            const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
            const networkId = await web3.eth.net.getId();
            const deployedNetwork = VotingContract.networks[networkId];

            // Get the contract instance.
            const instance = new web3.eth.Contract(
              VotingContract.abi,
              deployedNetwork && deployedNetwork.address,
            );

            // Set web3, accounts, and contract
            setProvider({web3: web3, accounts: accounts, contract: instance});

          } catch (error) {
            console.log(error);
          }

        }
        // Legacy dapp browsers...
        else if (window.web3) {

        }
      })();
    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  }

  useEffect(() => {
    document.title = "Voting London"
    window.ethereum.on('accountsChanged', () => {
      initWeb3();
    });
  }, [])

  if (!provider.web3) {
    return (
      <>
        <div className="header-app">
          <h1>Voting London - Alyra</h1>
        </div>
        <div className="main-before-web3-connect">
          <h3>If you are a voter, please connect with your address to access the voting panel and datas</h3>
          <button className="button-connect" onClick={initWeb3}>Connect wallet</button>
        </div>
      </>
    )
  }
  else {
    return ( 
      <>
        <div className="header-app">
          <h1>Voting London - Alyra</h1>
          <p className="current-user">Connected: {provider.accounts[0]}</p>
        </div>
        <div className="main-voting">
        <providerContext.Provider value={provider}>
          <VotingMain />
        </providerContext.Provider>
        </div>
      </>
    )
  }
}

export default App;
