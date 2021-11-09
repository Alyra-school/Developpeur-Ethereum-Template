const Gartic = artifacts.require("GarticPhone");
const { expectRevert, expectEvent } = require('@openzeppelin/test-helpers')
const { expect } = require('chai');

contract("Gartic", accounts => {
    const words = [ 'first', 'second',
                    'third', 'fourth',
                    'fifth', 'sixth',
                    'seventh', 'eighth',
                    'ninth', 'tenth',
                    'eleventh', 'twelfth',
                    'thirteenth', 'fourteenth',
                    'fifteenth', 'sixteenth',
                    'seventeenth', 'eighteenth',
                    'nineteenth', 'twentieth' ];
    const _firstWord = words[0];
    const starterOwner = accounts[0];
    const player2 = accounts[1];
    const player6 = accounts[5];
    const lastPlayer = accounts[19];

    beforeEach(async function() {
        this.gartic = await Gartic.deployed();
    })

    context("Put a word tests", function() {
        it("should put a new word in the chain", async function() {
            assert.equal(await this.gartic.getLastWord.call(), _firstWord, "Wrong first word");

            const _secondWord = words[1];
            await this.gartic.putNewWord(_secondWord, {from: player2});

            assert.equal(await this.gartic.getLastWord.call(), _secondWord, "Wrong new word");
        })
        it("should always reverts with the right reason", async function() {
            await expectRevert(this.gartic.putNewWord(words[2], {from: player2}), "address already played");
            await expectRevert(this.gartic.putNewWord(words[1], {from: accounts[2]}), "word is the same than the previous word");
            await expectRevert(this.gartic.putNewWord("", {from: accounts[2]}), "word can't be empty");
        })
    })

    context("retrieving words tests", function() {
        before(async function() {
            for(i = 3; i < 11; i++){
                await this.gartic.putNewWord(words[i - 1], {from: accounts[i - 1]});
            }
        })
        it("should retrieve the last word put: tenth", async function() {
            let word = await this.gartic.getLastWord.call();
            assert.equal(word, "tenth");
        })
        it("should revert transaction with: Ownable: caller is not the owner", async function() {
           await expectRevert(this.gartic.getAllWords.call({from: player2}), 'Ownable: caller is not the owner');
        })
        it("should return all the previous words put", async function() {
            let words = await this.gartic.getAllWords.call({from: starterOwner});
            expect(words).to.have.members(
                [   words[0], words[1], 
                    words[2], words[3], 
                    words[4], words[5], 
                    words[6], words[7], 
                    words[8], words[9]  ]
            );
        })
    })

    context("late game tests", function() {
        before(async function() {
            for(i = 11; i < 20; i++){
                await this.gartic.putNewWord(words[i - 1], {from: accounts[i - 1]});
            }
        })
        it("should put the last word and change the game state", async function() {
            let result = await this.gartic.putNewWord(words[19], {from: lastPlayer});

            let resultBlock = await web3.eth.getBlock(result.receipt.blockNumber);
            let expectedTimestamp = resultBlock.timestamp;
            let exptectedState = Gartic.gameStates.GUESS_WAITING;

            expectEvent(result, 'onStateChange', (ev) => {
                return ev.newState.toNumber() === exptectedState && ev.timestamp.toNumber() === expectedTimestamp;
            });
        })
        it("should try to put a word and revert", async function() {
            await expectRevert(this.gartic.putNewWord("tooMuch", {from: accounts[20]}), "you can't enter word anymore");
        })
        it("should try a word and don't emit the end of game", async function() {
            let result = await this.gartic.guessFirstWord("wrong", {from: player6});
            //guessCount: 0 -> 1
            expectEvent.notEmitted(result, 'onFinishedGame');
        })
        it("should try a word and emit the end of game and state change", async function() {
            let result = await this.gartic.guessFirstWord(_firstWord, {from: player6});
            //guessCount: 1 -> 2

            let resultBlock = await web3.eth.getBlock(result.receipt.blockNumber);
            let expectedTimestamp = resultBlock.timestamp;
            let expectedState = Gartic.gameStates.FINISHED;

            expectEvent(result, 'onFinishedGame', (ev) => {
                return ev.firstWord === _firstWord && ev.numberOfTry.toNumber() === 2;
            })
            expectEvent(result, 'onStateChange', (ev) => {
                return ev.newState.toNumber() === expectedState && ev.timestamp.toNumber() === expectedTimestamp;
            })
        })
    })
})