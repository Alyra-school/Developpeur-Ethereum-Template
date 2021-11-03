pragma solidity 0.8.9;

/** @notice Exercice - msg.sender 
    @author Loïs L.*/
contract Choice {
    mapping (address => uint) choices;

    function add(uint _myuint) external {
        choices[msg.sender] = _myuint;
    }
}