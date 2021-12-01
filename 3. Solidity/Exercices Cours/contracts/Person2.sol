pragma solidity 0.8.9;

/** @notice Exercice - Manipulation d'une struct Person
    @author Loïs L. */
contract Whitelist {
    struct Person {
        string name;
        uint age;
    }

    function addPerson(string memory _name, uint _age) external pure {
        Person memory p = Person(_name, _age);
    }
}