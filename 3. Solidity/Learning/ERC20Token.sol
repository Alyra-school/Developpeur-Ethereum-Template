// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {
    constructor(uint256 _initialSupply) ERC20("ALYRA", "ALY") {
        _mint(msg.sender,_initialSupply);
   }
}
