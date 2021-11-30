// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract Random{
    uint private nonce = 0;

    // retourne un entier entre 0 et 100;
    function random() public returns(uint){
        nonce++;
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 100; 
    }

}
