// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./IContratB.sol";

contract B is IContratB {
    uint nombre;

    function getNombre() external view returns (uint) {
        return nombre;
    }

    function setNombre(uint _nombre) external {
        nombre = _nombre;
    }
}