const Web3 = require("web3");
require('dotenv').config();

const web3 = new Web3(new Web3.providers.HttpProvider(`https://mainnet.infura.io/v3/${process.env.INFURA_ID}`));
web3.eth.getBalance("0x5A0b54D5dc17e0AadC383d2db43B0a0D3E029c4c", (err, result) => {
  if (err) console.log(err);
  else console.log(web3.utils.fromWei(result, "ether") + " ETH")
});

