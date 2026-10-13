// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ISimpleStorage {
    function setNumber(uint256 _number) external;
    function getNumber() external view returns(uint256);
}