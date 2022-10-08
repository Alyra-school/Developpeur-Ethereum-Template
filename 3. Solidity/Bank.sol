// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract Bank {

    mapping (address => uint) balance;

    function deposit(uint _amount) public {
        balance[msg.sender] += _amount;
    }

    function transfer(address _recipient, uint _amount) public {
        require (_recipient != address(0), "You can't burn tokens");
        require (balance[msg.sender] >= _amount, "You don't have enough tokens");
        balance[msg.sender] -= _amount;
        balance[_recipient] += _amount;
    }

    function banceOf(address _address) public view returns(uint) {
        return balance[_address];
    }
}
