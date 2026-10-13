// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IContratB {
    function getNombre() external view returns (uint);
    function setNombre(uint _nombre) external;
}