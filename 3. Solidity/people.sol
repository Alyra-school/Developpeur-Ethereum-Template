// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract People {
    struct Person {
        string name;
        uint age;
    }


    Person[] persons;
    uint public personsLength;

    function add(string memory _name, uint8 _age) public {
        persons.push(Person(_name, _age));
        personsLength = persons.length;
    }

    function remove() public {
        persons.pop();
        personsLength = persons.length;
    }
    
}
