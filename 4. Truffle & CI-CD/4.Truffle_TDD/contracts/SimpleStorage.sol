// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract SimpleStorage {
    uint data;
    address owner;
    event DataStored(uint _data, address _address);
    
    constructor() {
        owner = msg.sender;
    }

    function set(uint _x) public {
        require(_x > 0, "vous ne pouvez pas mettre une valeur nulle");
        data = _x;
        emit DataStored(_x, msg.sender);
    }
    
    function get() public view returns (uint) {
        return data;
    }

    function returnOwner() public view returns (address) {
        return owner;
    }
}