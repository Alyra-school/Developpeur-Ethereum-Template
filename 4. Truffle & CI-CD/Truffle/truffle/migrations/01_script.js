const Storage = artifacts.require("Storage");

module.exports=(deployer) => {
    deployer.deploy(Storage)
}