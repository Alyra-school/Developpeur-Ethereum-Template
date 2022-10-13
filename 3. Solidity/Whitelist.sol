pragma solidity >= 0.8.13;

contract Whitelist {

    mapping(address => bool) whitelist;

    event Authorized(address _address);
    event EthRecieved(address _address, uint _value);

    function authorize(address _address) public check {
        whitelist[_address] = true;
        emit Authorized(_address);
    }

    recieve() external payable {
        emit EthRecieved(msg.sender, msg.value);

    }

    fallback() external payable() {
        emit EthRecieved(msg.sender, msg.value);
    }

    modifier check() {
        require(whitelist[msg.sender], "Unauthorized");
    }
}