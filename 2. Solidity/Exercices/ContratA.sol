// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./IContratB.sol";

contract A {
    IContratB addressB;

    constructor(IContratB _addressB) {
        addressB = _addressB;
    }

    function appelGetNombre() external view returns (uint) {
        return addressB.getNombre();
    }

    function appelSetNombre(uint _nombre) external {
        addressB.setNombre(_nombre);
    }
}