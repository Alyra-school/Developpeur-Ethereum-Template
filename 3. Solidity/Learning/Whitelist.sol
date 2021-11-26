// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Whitelist {
	mapping (address => bool) whiteList ;
	struct Person{ //structure de données
		string name;
		uint age;
	}

	function addPersonn (string memory _name, uint _age) public pure {
		Person memory unePersonne = Person(_name, _age);
	}
}
