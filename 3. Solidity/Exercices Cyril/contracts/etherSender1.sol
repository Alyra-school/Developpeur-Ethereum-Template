pragma solidity 0.8.9;

contract etherSender {
    event transfersDone(address sender, address receiver, uint value);

    /** @notice send ethers from 'msg.sender' to another address and emit
        @param _to receiver address */
    function sendEthers(address payable _to) public payable {
        _to.transfer(msg.value);

        emit transfersDone(msg.sender, _to, msg.value);
    }
}