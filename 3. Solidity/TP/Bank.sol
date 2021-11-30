// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract Bank{
    mapping (address => uint) _balances; //Soldes détenus par un compte
    
    modifier verifSolde(uint _amount){
        require(_amount <= _balances[msg.sender]);
        _;
    }
    
    //Pas besoin de mettre external payabe, pourquoi ?
    function deposit(uint _amount) public {
        require(msg.sender != address(0), "You cannot deposit for the address zero");
        _balances[msg.sender] += _amount; //On dépose le nouveau montant qu'on ajoute à l'ancien
    }

    // Transférer les fonds si le montant à transférer < montant du compte du msg.sender
    function transfer(address _recipient, uint _amount) public verifSolde(_amount){
        require(msg.sender != address(0), "You cannot transfer for the address zero");
        _balances[msg.sender] -= _amount;
        _balances[_recipient] += _amount;
    }

    function balanceOf(address _address) public view returns(uint){
        return _balances[_address];
    }
}
