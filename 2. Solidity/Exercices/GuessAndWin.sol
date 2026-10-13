// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

error hasAlreadyPlayed(address _user);
error GameAlreadyWon(address _winner);

contract GuessAndWin is Ownable {
    

    string private word;
    string private clue;
    address winner;

    mapping(address => bool) hasPlayed;

    event GameWon(address indexed _winner);

    constructor() Ownable(msg.sender) {

    }

    function guess(string calldata _word) external returns(bool) {
        require(!hasPlayed[msg.sender], hasAlreadyPlayed(msg.sender));
        require(winner == address(0), GameAlreadyWon(winner));
        hasPlayed[msg.sender] = true;
        if(compareStrings(_word, word)) {
            winner = msg.sender;
            emit GameWon(msg.sender);
            return true;
        }
        return false;
    }

    function setWordAndClue(string calldata _word, string calldata _clue) external onlyOwner {
        word = _word;
        clue = _clue;
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function getClue() external view returns(string memory) {
        return clue;
    }

    function getWinner() external view returns(address) {
        return winner;
    }

}