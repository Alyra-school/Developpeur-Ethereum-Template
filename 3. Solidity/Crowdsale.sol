pragma solidity >= 0.8.15;

import "./Token.sol";

contract Crowdsale {
    uint public rate = 200;     // current conversion rate for 1ETH
    Token public token;

    constructor(uint256 initialSupply) {
        token = new Token(initialSupply);
    }

    recieve() external payable {
        require(msg.value >= 0.1 ether, "Min amount to send 0.1 ether");
        distribute(msg.value);
    }

    function distribute(uint256 amount) internal {
        uint256 tokenToSent = amount * rate;
        token.transfer(msg.sender, tokenToSent);
    }
}