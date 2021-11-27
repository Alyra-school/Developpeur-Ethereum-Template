// SPDX-License-Identifier: MIT
pragma solidity >=0.4.21 <0.8.10;

contract SimpleStorage {
  uint storedData;

  event newSet(uint x);

  function set(uint x) public {
    storedData = x;

    emit newSet(x);
  }

  function get() public view returns (uint) {
    return storedData;
  }
}
