// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ERC20Token is ERC20 {
    uint public rate = 200;
    uint public minInvest = 100000000000000000 wei; //0.1 etc = 1*10^18 / 10 = 10^17

    constructor() ERC20("ALYRA", "ALY") {

   }
}
