// SPDX-License-Identifier: GPL-3.0
// contract deployed to 0x3AAE0f4143a49f01ea7A9714B0d13Cfa33a61daa (sepolia network)

pragma solidity >=0.8.0 <0.9.0;
 
contract SimpleStorage {
   uint data;
 
   function set(uint x) public {
       data = x;
   }
 
   function get() public view returns (uint) {
       return data;
   }
}
