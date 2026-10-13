// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "./ISimpleStorage.sol";

contract Interact {

    ISimpleStorage simpleStorageAddress;

    constructor(ISimpleStorage _simpleStorageAddress) {
        simpleStorageAddress = _simpleStorageAddress;
    }

    function getNumber() external view returns(uint256) {
        return simpleStorageAddress.getNumber();
    }

}