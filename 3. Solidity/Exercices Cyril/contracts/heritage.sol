pragma solidity 0.8.9;

contract Parent {
    uint _storage;

    function setStorage(uint _s) external {
        _storage = _s;
    }
}

contract Enfant is Parent {
    function getStorage() external view returns(uint){
        return _storage;
    }
}

contract caller {
    Enfant enfant = new Enfant();

    function setStorageFromCaller(uint _s) private returns(uint){
        enfant.setStorage(_s);
        return enfant.getStorage();
        //return enfant._storage;
    }
}