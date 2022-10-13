pragma solidity >= 0.8.15;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Admin is Ownable {
    mapping(address => bool) whitelist;
    mapping(address => bool) blacklist;

    event AuthorizedEvent(address _address);
    event BannedEvent(address _address);

    function ban(address _address) public onlyOwner {
        require(!blacklist[_address], "Already blacklist");
        require(!whitelist[_address], "Already whitelist");
        blacklist[_address] = true;
        emit BannedEvent(blacklist[_address]);
    }

    function authorize(address _address) public onlyOwner {
        require(!whitelist[_address], "Already whitelist");
        require(!blacklist[_address], "Already blacklist");
        whitelist[_address] = true;
        emit AuthorizedEvent(whitelist[_address]);
    }

    function isWhitelisted(address _address) public view returns(bool) {
        return whitelist[_address];
    }

    function isBlacklisted(address _address) public view returns(bool) {
        return blacklist[_address];
    }


}