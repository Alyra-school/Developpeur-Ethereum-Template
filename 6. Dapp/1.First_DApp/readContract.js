const Web3 = require('web3');
const rpcURL = "https://ropsten.infura.io/v3/461e417d912441f78958e476ebc11f47"
const web3 = new Web3(rpcURL)
const SSAddress = "0xCbd43b4CF42101693689a1f9C201471d8f505E8f";
const account1 = '0x7aaEd0BF529a4E928C14c1B0Ba24bB71E0E7E641'; // Your account address 1
// const privateKey1 = Buffer.from(process.env.PRIVATE_KEY, 'hex');

const ABI = [
	{
		"inputs": [],
		"name": "get",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "x",
				"type": "uint256"
			}
		],
		"name": "set",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
]

const simpleStorage = new web3.eth.Contract(ABI, SSAddress);

simpleStorage.methods.set(69).send({from: account1})
    .then(receipt => {
        console.log(receipt);
    });

simpleStorage.methods.get().call((err, data) => {
    console.log(data);
});