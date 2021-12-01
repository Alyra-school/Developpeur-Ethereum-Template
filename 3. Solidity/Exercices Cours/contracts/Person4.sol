pragma solidity 0.8.9;

/** @notice Exercice - Array (avancé)
    @author Loïs L. */
contract Whitelist {
    struct Person {
        string name;
        uint age;
    }

    Person[] persons;

    function add(string memory _name, uint _age) external {
        persons.push(Person(_name, _age));
    }

    function remove() external {
        persons.pop();
    }
}