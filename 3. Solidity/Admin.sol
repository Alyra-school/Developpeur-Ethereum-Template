// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.14;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Admin is Ownable {

    mapping (address => bool) whitelistMapping;
    mapping (address => bool) blacklistMapping;

    event Whitelisted(address _whitelistedAddr);
    event Blacklisted(address _whitelistedAddr);

    function whitelist(address _addrToWhitelist) public onlyOwner {
        require(!blacklistMapping[_addrToWhitelist], "Already blacklisted");
        require(!whitelistMapping[_addrToWhitelist], "Already whitelisted");
        whitelistMapping[_addrToWhitelist] = true;
        emit Whitelisted(_addrToWhitelist);
    }

    function blacklist(address _addrToBlacklist) public onlyOwner {
        require(!blacklistMapping[_addrToBlacklist], "Already blacklisted");
        require(!whitelistMapping[_addrToBlacklist], "Already whitelisted");
        blacklistMapping[_addrToBlacklist] = false;
        emit Blacklisted(_addrToBlacklist);
    }

    function isWhitelisted(address _addr) public view returns(bool){
        return whitelistMapping[_addr];
    }

    function isBlacklisted(address _addr) public view returns(bool){
        return blacklistMapping[_addr];
    }
}
