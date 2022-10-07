// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract Score {

    mapping (address => uint8[]) public scores;

    function addScore(address _student, uint8 _score) public {
        scores[_student].push(_score);
    }

}
