// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract HelloWorld {

string myString = "Hello World";

	function hello() public view returns(string memory){
        return myString;
    }
}
