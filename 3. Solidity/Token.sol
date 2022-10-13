pragma solidity >= 0.8.15;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {

    constructor(uint256 initialSupply) ERC20('learn2earn', 'L2E') {
        _mint(msg.sender, initialSupply);
    }
}