// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

error InsufficientValue();
error DelayedTimeNotReached();
error FailedToSendEthers();

contract Bank is Ownable {

    uint256 unlockTime;
    uint256 depositId;

    mapping(uint256 => uint256) deposits;

    constructor() Ownable(msg.sender) {

    }

    function deposit() external payable onlyOwner {
        require(msg.value > 0, InsufficientValue());
        depositId++;
        if(unlockTime == 0) {
            unlockTime = block.timestamp + 90 days;
        }
    }

    function withdraw() external onlyOwner {
        require(block.timestamp >= unlockTime, DelayedTimeNotReached());
        (bool sent,) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, FailedToSendEthers());
    }

}