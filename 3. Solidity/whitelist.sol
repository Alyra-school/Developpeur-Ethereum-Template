// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract Whitelist {

    mapping (address => bool) whitelist;

    event Authorized(address _address);
    
    constructor() {
        whitelist[msg.sender] = true;
    }

    modifier check() {
        require(whitelist[msg.sender] == true, "Not authorized");
        _;
    }

    function authorize(address _address) public check {
        whitelist[_address] = true;
        emit Authorized(_address);
    }

}
