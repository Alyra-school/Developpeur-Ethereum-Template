// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract KingOfEther {
    address public king;
    uint256 public balance;

    event ThroneClaimed(address indexed _user, uint256 _value);

    function getKing() external view returns(address) {
        return king;
    }

    function twoPlusTwo() external pure returns(uint256) {
        return 2 + 2;
    }

    function claimThrone() external payable {
        require(msg.value > balance, "Need to pay more to become the king");

        (bool sent,) = king.call{value: balance}("");
        require(sent, "Failed to send Ether");

        balance = msg.value;
        king = msg.sender;

        emit ThroneClaimed(msg.sender, msg.value);
    }
}

// ThroneClaimed(addr1, 0.4543532 ETH)
// ThroneClaimed(addr2, 0.3 ETH)
// ThroneClaimed(addr3, 0.2 ETH)
// ThroneClaimed(addr4, 0.1 ETH)
// ThroneClaimed(addr5, 0.005 ETH)