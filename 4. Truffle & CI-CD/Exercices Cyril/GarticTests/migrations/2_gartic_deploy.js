const Gartic = artifacts.require("GarticPhone");

module.exports = function (deployer) {
  deployer.deploy(Gartic, "first");
};