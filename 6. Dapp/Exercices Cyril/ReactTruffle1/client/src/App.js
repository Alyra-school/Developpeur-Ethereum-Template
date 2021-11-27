import React, { useState, useEffect } from "react";
import SimpleStorageContract from "./contracts/SimpleStorage.json";
import getWeb3 from "./getWeb3";

import "./App.css";

function App(){
  const [storageValue, setStorageValue] = useState(0);
  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState(null);
  const [contract, setContract] = useState(null);

  useEffect(() => {
    async function initWeb3(){
      try {
        // Get network provider and web3 instance.
        let _web3 = await getWeb3();
  
        // Use web3 to get the user's accounts.
        let _accounts = await _web3.eth.getAccounts();
  
        // Get the contract instance.
        const networkId = await _web3.eth.net.getId();
        const deployedNetwork = SimpleStorageContract.networks[networkId];
        const instance = new _web3.eth.Contract(
          SimpleStorageContract.abi,
          deployedNetwork && deployedNetwork.address,
        );
  
        await instance.events.newSet(null, function (error, event) {
          if (!error) {
            console.log("Event success ! ");
            console.log(event.returnValues);
          } else console.log(error);
        });
  
        // Set web3, accounts, and contract to the state, and then proceed with an
        // example of interacting with the contract's methods.
        setWeb3(_web3);
        setAccounts(_accounts);
        setContract(instance);
      } catch (error) {
        // Catch any errors for any of the above operations.
        alert(
          `Failed to load web3, accounts, or contract. Check console for details.`,
        );
        console.error(error);
      }
    }

    initWeb3();
  }, [])

  const runExemple = async () => {
    // Stores a given value, 5 by default.
    let receipt = await contract.methods.set(5).send({ from: accounts[0] });
    //console.log(receipt.events.name);

    // Get the value from the contract to prove it worked.
    const response = await contract.methods.get().call();

    // Update state with the result.
    setStorageValue(response);
  }

  if (!web3) {
    return <div>Loading Web3, accounts, and contract...</div>;
  }
  return (
    <div className="App">
      <h1>Good to Go!</h1>
      <p>Your Truffle Box is installed and ready.</p>
      <h2>Smart Contract Example</h2>
      <p>
        If your contracts compiled and migrated successfully, below will show
        a stored value of 5 (by default).
      </p>
      <p>
        Try changing the value stored on <strong>line 42</strong> of App.js.
      </p>
      <div>The stored value is: {storageValue}</div>
      <div>
        <button onClick={runExemple}>Set</button>
      </div>
      <div className="EventsLog">
      </div>
    </div>
  );
}

/**
class App extends Component {
  state = { storageValue: 0, eventsLog: [], web3: null, accounts: null, contract: null };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      const accounts = await web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = SimpleStorageContract.networks[networkId];
      const instance = new web3.eth.Contract(
        SimpleStorageContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ web3, accounts, contract: instance });

      await instance.events.newSet(null, function (error, event) {
        if (!error) {
          console.log("Event success ! ");
          console.log(event.returnValues);
        } else console.log(error);
      });

    } catch (error) {
      // Catch any errors for any of the above operations.
      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };

  runExample = async () => {
    const { accounts, contract } = this.state;

    // Stores a given value, 5 by default.
    let receipt = await contract.methods.set(5).send({ from: accounts[0] });
    //console.log(receipt.events.name);

    // Get the value from the contract to prove it worked.
    const response = await contract.methods.get().call();

    // Update state with the result.
    this.setState({ storageValue: response });
  };

  render() {
    if (!this.state.web3) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Good to Go!</h1>
        <p>Your Truffle Box is installed and ready.</p>
        <h2>Smart Contract Example</h2>
        <p>
          If your contracts compiled and migrated successfully, below will show
          a stored value of 5 (by default).
        </p>
        <p>
          Try changing the value stored on <strong>line 42</strong> of App.js.
        </p>
        <div>The stored value is: {this.state.storageValue}</div>
        <div>
          <button onClick={this.runExample}>Set</button>
        </div>
        <div className="EventsLog">
          {this.state.eventsLog}
        </div>
      </div>
    );
  }
}*/

export default App;
