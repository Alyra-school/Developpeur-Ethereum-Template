const SimpleStorage = artifacts.require("SimpleStorage");

module.exports = async function (deployer) {
  await deployer.deploy(SimpleStorage);
};
