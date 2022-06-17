const SimpleStorage = artifacts.require("SimpleStorage");

module.exports = async function (deployer) {
  await deployer.deploy(SimpleStorage, 13, {value: 11});
  let instance = await SimpleStorage.deployed();
  let number = await instance.get();
  console.log(number.toString());
};
