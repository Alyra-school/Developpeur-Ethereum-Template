require('dotenv').config();

var  Web3  =  require('web3'); 
var web3  =  new  Web3(new  Web3.providers.HttpProvider('https://ropsten.infura.io/v3/' + process.env.INFURA_ID));

console.log('Calling Contract.....');

var  abi  =  [{"inputs":[{"internalType":"address","name":"_addr1","type":"address"},{"internalType":"address","name":"_addr2","type":"address"},{"internalType":"address","name":"_addr3","type":"address"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"inputs":[],"name":"getAddresses","outputs":[{"components":[{"internalType":"uint16","name":"id","type":"uint16"},{"internalType":"uint16","name":"ratio","type":"uint16"},{"internalType":"address","name":"addr","type":"address"}],"internalType":"struct Dispatch.Addr[3]","name":"","type":"tuple[3]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint16","name":"_ratio1","type":"uint16"},{"internalType":"uint16","name":"_ratio2","type":"uint16"},{"internalType":"uint16","name":"_ratio3","type":"uint16"}],"name":"setRatios","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}];
var  addr  =  "0x3ec295999d5c9bA0DcED4b651740b6Edc176Be98";

var  Contract  =  new  web3.eth.Contract(abi, addr);

// FUNCTION must the name of the function you want to call. 
Contract.methods.owner().call().then(console.log);