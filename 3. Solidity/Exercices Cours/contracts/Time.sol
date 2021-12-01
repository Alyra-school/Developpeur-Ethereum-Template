pragma solidity 0.8.9;

/** @notice Exercice - Variable spéciale
    @author Loïs L. */
contract Time {
    function getTime() external view returns(uint){
        return block.timestamp;
    }
}