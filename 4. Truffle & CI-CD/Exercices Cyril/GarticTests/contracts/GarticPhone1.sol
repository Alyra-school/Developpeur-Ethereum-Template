pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

/** @notice A simple gartic phone game on-chain
    @author Loïs L. */
contract GarticPhone is Ownable {
    /** @dev store all the words played */
    string[] private wordsChain;
    /** store how many try of guess got effectued */
    uint guessCount;
    /** @dev track how many words got played and is stored in 'wordsChain' */
    uint8 private wordsCount;
    /** @dev index for an address if address have put a word in the game 
    (1 word per address possible) */
    mapping (address => bool) private havePlayed;
    /** @notice contains the state of the game */
    gameStates public state;
    /** @param RUNNING the game is running and players can propose a word
        @param GUESS_WAITING 20 words is played and contract wait a correct guess in 'guessFirstWord()' 
        @param FINISHED the game is finished */
    enum gameStates{RUNNING, GUESS_WAITING, FINISHED}

    /** @notice construct the contract and initialize the game with the first word
        @param _firstWord the first word to start the game */
    constructor(string memory _firstWord){
        require(keccak256(abi.encode(_firstWord)) != keccak256(abi.encode("")), "word can't be empty");

        state = gameStates.RUNNING;
        wordsChain.push(_firstWord);
        wordsCount = 1;
        havePlayed[msg.sender] = true;

        emit onStateChange(state, block.timestamp);
    }

    /** @notice put a new word in the game and disallow 'msg.sender' to put other words 
        @param _word the word to put in the word chain */
    function putNewWord(string memory _word) public {
        require(keccak256(abi.encode(_word)) != keccak256(abi.encode("")), "word can't be empty");
        require(state == gameStates.RUNNING, "you can't enter word anymore");
        require(havePlayed[msg.sender] == false, "address already played");
        require(keccak256(abi.encode(_word)) != keccak256(abi.encode(wordsChain[wordsCount - 1])), "word is the same than the previous word");

        wordsChain.push(_word);
        havePlayed[msg.sender] = true;
        wordsCount++;

        //if word chain have 20 word, the game get in GUESS WAITING Mode
        if(wordsCount == 20){
            state = gameStates.GUESS_WAITING;
            emit onStateChange(state, block.timestamp);
        }
    }

    /** @notice get the last word of the chain, accessing by all the player who wanna put a word or guess 
        @return the last word of the chain*/
    function getLastWord() public view returns(string memory){
        return wordsChain[wordsCount - 1];
    }

    /** @notice get all the words of the chain, accessing only by the contract owner (the game starter) */
    function getAllWords() public view onlyOwner() returns(string[] memory){
        return wordsChain;
    }

    /** @notice try to guess what was the first word of the chain 
        @param _word the word to try */
    function guessFirstWord(string memory _word) external {
        require(state == gameStates.GUESS_WAITING, "the game isn't in guess mode");
        require(keccak256(abi.encode(_word)) != keccak256(abi.encode("")), "word can't be empty");
        guessCount++;

        if(keccak256(abi.encode(_word)) == keccak256(abi.encode(wordsChain[0]))){
            state = gameStates.FINISHED;

            emit onStateChange(state, block.timestamp);
            emit onFinishedGame(wordsChain[0], guessCount);
        }
    }

    event onStateChange(gameStates newState, uint timestamp);
    event onFinishedGame(string firstWord, uint numberOfTry);
}