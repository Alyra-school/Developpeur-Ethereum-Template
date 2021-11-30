// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Admin is Ownable{
    event WhiteListed (address _address);
    event BlackListed (address _address);

    mapping (address => bool) private comptesWL;
    mapping (address => bool) private comptesBL;

    function whitelist(address _address) public onlyOwner{
        require(!comptesWL[_address],"deja WL");
        require(!comptesBL[_address],"deja BL");
        comptesWL[_address] = true;
        emit WhiteListed(_address);
    }

    function blacklist(address _address) public onlyOwner{
        require(!comptesBL[_address],"deja BL");
        require(!comptesWL[_address],"deja WL");
        comptesBL[_address] = false;
        emit BlackListed(_address);
    }

    function isWhiteListed(address _address) public view returns(bool){
        return comptesWL[_address];
    }

    function isBlackListed(address _address) public view returns(bool){
        return comptesBL[_address];
    }
}
