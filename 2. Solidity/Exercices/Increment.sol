// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

error InsufficientBalance();

contract Increment {

    address myAddress;

    modifier enoughEther() {
        require(msg.value >= 1 wei, "Please send at least 1 Wei");
        _;
    }

    function getMyAddress() external view returns(address) {
        return myAddress;
    }

    function setMyAddress(address _myAddress) external {
        myAddress = _myAddress;
    }

    function getBalance() external view returns(uint256) {
        return myAddress.balance;
    }

    function getBalanceOfAddress(address _userAddress) external view returns(uint256) {
        return _userAddress.balance;
    }

    function sendViaTransfer(address payable _to) external payable {
        require(msg.value >= 1 wei, "Please send at least 1 Wei");
        // if(msg.value < 1 wei) {
        //     revert("Please send at least 1 Wei");
        // }
        // if(msg.value < 1 wei) {
        //     revert InsufficientBalance();
        // }
        // require(msg.value >= 1 wei, InsufficientBalance());
        _to.transfer(msg.value);
    }

    function sendViaSend(address payable _to) external payable enoughEther {
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address payable _to) external payable enoughEther {
        (bool sent,) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }

    function sendIfEnoughEther(uint256 _balance) external payable {
        if(myAddress.balance <= _balance) {
            revert InsufficientBalance();
        }
        (bool sent,) = payable(myAddress).call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        // require(myAddress.balance > _balance, "no");
        // require(myAddress.balance > _balance, InsufficientBalance());
    }

}