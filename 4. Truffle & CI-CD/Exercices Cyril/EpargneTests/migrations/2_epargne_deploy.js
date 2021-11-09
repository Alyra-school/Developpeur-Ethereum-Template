const OwnerBank = artifacts.require("OwnerBank");

module.exports = function (deployer) {
  deployer.deploy(OwnerBank);
};