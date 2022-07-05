const SPA = artifacts.require("SPA");
const { expect } = require('chai');
const { BN, expectRevert, expectEvent } = require('@openzeppelin/test-helpers');

contract("SPA", (accounts) => {
    const owner = accounts[0];
    let spaInstance;

    describe("New animal", function () {
        beforeEach(async () => {
            spaInstance = await SPA.new({ from : owner });
        })

        it("should revert error if species is empty", async () => {
            await expectRevert(
                spaInstance.newAnimal("", 122, 21, { from: owner }),
                "Species must not be empty"
            )
        });

        it("should revert error if size is not > 0", async () => {
            await expectRevert(
                spaInstance.newAnimal("cat", 0, 21, { from: owner }),
                "Size must be superior to 0"
            )
        });

        it("should revert error if age is not > 0", async () => {
            await expectRevert(
                spaInstance.newAnimal("cat", 10, 0, { from: owner }),
                "Age must be superior to 0"
            )
        });

        it("should return animal created in array", async () => {
            // console.log(await spaInstance.newAnimal("cat", 30, 1))
            expectEvent(
                await spaInstance.newAnimal("cat", 30, 1),
                "AnimalCreated",
                {
                    _specie: "cat",
                    _size: new BN(30),
                    _age: new BN(1),
                    _isAdopted: false,
                }
            )
        })
    });
})