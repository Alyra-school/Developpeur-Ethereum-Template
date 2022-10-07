// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

contract Whitelist {

    mapping (address => bool) whitelist;

    event Authorized(address _address);

}
