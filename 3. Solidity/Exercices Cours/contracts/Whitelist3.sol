pragma solidity 0.8.9;

/** @notice Exercice - Whitelist
    @author Loïs L. */
contract Whitelist {
    mapping (address => bool) whitelist;

    function authorize(address _address) public {
        whitelist[_address] = true;
        emit Authorized(_address);
    }

    event Authorized(address addr);
}