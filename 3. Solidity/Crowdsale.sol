// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

import "./ERC20Token.sol";

contract Crowdsale {
    uint public rate = 200;
    ERC20Token public token;

    constructor(uint initialSupply) {
        token = new ERC20Token(initialSupply);
    }

    receive() external payable {
        require(msg.value >= 0.1 ether, "Not enough ethers sent. Minimum of 0.1 ether must be sent.");
        distribute(msg.value);
    }

    function distribute(uint amount) internal {
        token.transfer(msg.sender, amount*rate);
    }
}
