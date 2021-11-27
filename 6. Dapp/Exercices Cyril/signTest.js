var  Web3  =  require('web3');
require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');

provider = new HDWalletProvider(`${process.env.MNEMONIC}`, `https://ropsten.infura.io/v3/${process.env.INFURA_ID}`, 1);
let web3 = new Web3(provider);

const tx = {
      from: '0x947a76Faaf2Cc6Ce1A7F77cCd00e64794Ad31419', 
      to: '0x5E18a57d9CEb6fB1927F80FbB1796A6B9f43Dc38', 
      value: 100000000000000000,
};

const signPromise = web3.eth.signTransaction(tx, tx.from);

signPromise.then((signedTx) => {  
        const sentTx = web3.eth.sendSignedTransaction(signedTx.raw || signedTx.rawTransaction);    
        sentTx.on("receipt", receipt => {
            console.log("super");
        });
        sentTx.on("error", err => {
          console.log("oopsie");
        });
    }).catch((err) => {
        console.log("oupsie2");
});