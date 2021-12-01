pragma solidity 0.8.9;

abstract contract Storage {
    function store(uint256 num) public{}
    function retrieve() public view returns (uint256){}
}

contract Heritage2 {
    Storage private _storage = Storage(0xE9e1c1CC91950C424631addbd812d960e9505b47);

    function store(uint _num) external {
        _storage.store(_num);
    }

    function retrieve() external view returns(uint){
        return _storage.retrieve();
    }
}