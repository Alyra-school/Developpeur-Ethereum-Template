// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;


contract Parent {
    uint256 internal number;
    function setNumber(uint256 _number) external {
        number = _number;
    }
}

contract Child is Parent {
    function getValue() external view returns(uint256) {
        return number;
    }
}


contract Caller {

    Child cc = new Child();

    function testInheritance() external returns(uint256) {
        cc.setNumber(777);
        return cc.getValue();
    }

}