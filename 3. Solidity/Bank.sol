pragma solidity >= 0.8.15;

contract Bank {

    uint256 creationDate;
    mapping(address => uint) balances;

    function deposit(uint amount) public {
        balances[msg.sender] += amount;
    }

    function transfer(address to, uint amount) public {
        require (to != address(0), "Can't send your own token");
        // require(balanceOf(from) > 0, "No money honey !");
        require(balances[msg.sender] >= amount, "No money honey !");
        balances[to] += amount;
        balances[msg.sender] -= amount;
    }

    function balanceOf(address _address) public view returns(uint) {
        return balances[_address];
    }
}