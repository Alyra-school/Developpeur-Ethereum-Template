const {BN} = require("@openzeppelin/test-helpers");
const Token = artifacts.require("Token");

contract("Token", accounts => {
    context("Datas verification", function () {
        it("should return the correct token name: TokenTest", async function() {
            const tokenInstance = await Token.deployed();

            let tokenName = await tokenInstance.name.call();
            assert.equal(tokenName, "TokenTest", "wrong token name");
        })

        it("should return the correct token symbol: TTst", async function() {
            const tokenInstance = await Token.deployed();
            
            let tokenSymbol = await tokenInstance.symbol.call();
            assert.equal(tokenSymbol, "TTst", "wrong token symbol");
        })
    })

    context("Balance/Transfers verification", function () {
        it("should return the correct amount in balance: 1000000", async function() {
            const tokenInstance = await Token.deployed();
            let expected = new BN(1000000 * 10 ** 18);

            let balance = await tokenInstance.balanceOf(accounts[0]);
            assert.equal(balance, expected);
        })
    })
})

