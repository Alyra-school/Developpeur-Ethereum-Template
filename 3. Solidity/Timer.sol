pragma solidity 0.8.15;

contract Timer {
    function getTime() public view returns(uint) {
        return block.timestamp;
    }
}