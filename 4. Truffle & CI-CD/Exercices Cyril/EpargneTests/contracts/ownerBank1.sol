// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Epargne is Ownable {

    // address admin;
    uint dateMinimum;
    uint depotID;

    mapping (uint => uint) depots;

    event nouvelleEpargne(uint dateMinimum);
    event argentDepose(uint date, uint value);
    
    //constructor(){
    //    admin=msg.sender;
    //}

    receive() external payable{
        if(address(this).balance == 0){
            dateMinimum=block.timestamp+ 12 weeks;
            emit nouvelleEpargne(dateMinimum);
        }
        depotID+=1;
        depots[depotID]=msg.value;
        emit argentDepose(block.timestamp,msg.value);
    }

    function sendEth() public payable{
        if(address(this).balance - msg.value == 0){
            dateMinimum=block.timestamp+ 12 weeks;
            emit nouvelleEpargne(dateMinimum);
        }
        depotID+=1;
        depots[depotID]=msg.value;
        emit argentDepose(block.timestamp,msg.value);
    }

    function withdrawEth() public onlyOwner {
        // require(msg.sender==admin, "tu n'es pas l'admin de ce contrat");
        require(block.timestamp>=dateMinimum, "tu n'as pas attendu assez longtemps");
        payable(msg.sender).transfer(address(this).balance);
    }

    function getBalance() public view onlyOwner returns(uint){
        return address(this).balance;
    }
}