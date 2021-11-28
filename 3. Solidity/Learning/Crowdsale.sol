// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./ERC20Token.sol";
 
contract Crowdsale {  
    ERC20Token public token; // L’instance ERC20Token à déployer 
    
    uint public rate = 200; // le taux à utiliser
    uint public minInvest = 100000000000000000 wei; //0.1 etc = 1*10^18 / 10 = 10^17
    uint private initialSupply = 1000*10^18;
    
    constructor(uint256 _initialSupply) {
       token = new ERC20Token(_initialSupply); // crée une nouvelle instance du smart contract ERC20Token ! L’instance ERC20Token déployée sera stockée dans la variable “token” 
    }

    receive() external payable {
        require(msg.value >= 0.1 ether,"0.1 eth minimum");
        distribute(msg.value);
    }

    function distribute(uint256 _amount) internal {
        uint256 tokenToSent = _amount * rate;
        token.transfer(msg.sender,tokenToSent);
    }
}

/*
hyp : 1 ether = 200€ => 10^18 wei = 200€
1€ = 10^18 wei / 200€
    = 10^18 / 2 * 100
    = 5*10^15
10^18 ALYbits = 1 ALY = 1€ => 5*10^15 wei = 10^18 alybits
                            10^15 = 2*10^17
                            10^15 = 2*(10*10*10^15)
                            1 wei = 200 alybits
*/

