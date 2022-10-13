pragma solidity >= 0.8.13;

contract People {
    Person public moi;
    Person[] public persons;

    struct Person {
        string name;
        uint age;
    }

    function modifyPerson(string memory _name, uint _age) public {
        moi = Person(_name, _age);
    }

    function add(string memory _name, uint _age) public {
        persons.push(
            Person(_name, _age)
        );
    }

    function removeLast() public {
        persons.pop();
    }
}