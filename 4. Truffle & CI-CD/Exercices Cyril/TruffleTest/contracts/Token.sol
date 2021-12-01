pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("TokenTest", "TTst") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}