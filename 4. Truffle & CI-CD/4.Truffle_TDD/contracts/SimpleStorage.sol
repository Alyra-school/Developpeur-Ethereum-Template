// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
 
contract SimpleStorage {
    constructor(uint _number) payable {
        set(_number);
    }

    uint data;
    
    function set(uint x) public {
        data = x;
    }
    
    function get() public view returns (uint) {
        return data;
    }
}