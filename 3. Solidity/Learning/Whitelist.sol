// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Whitelist {
	event Authorized(address _address); //Event à déclencher et intercepter dans le front
	mapping (address => bool) whiteList ;
	
	struct Person{ //structure de données
		string name;
		uint age;
	}

	Person[] public persons;

	function addPersonn (string memory _name, uint _age) public {
		Person memory unePersonne = Person(_name, _age); //créaation de la personne
		persons.push(unePersonne); //ajout de la personne au tableau de "Person"
	}

	function removePerson() public {
		persons.pop(); //Retire de le dernier élément de persons
	}

	function authorize(address _address) public {
		whiteList[_address] = true;
		emit Authorized(_address);
	}

}
