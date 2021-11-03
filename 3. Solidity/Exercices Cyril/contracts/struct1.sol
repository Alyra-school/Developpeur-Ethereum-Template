pragma solidity 0.8.9;

contract struct1 {
    struct Item{
        string name;
        uint price;
        uint units;
    }
    Item[] items;

    function addItem(string memory _name, uint _price, uint _units) public {
        require(_price > 0);
        require(_units > 0);
        items.push(Item(_name, _price, _units));

        emit newItem(_name, _price, _units);
    }

    function getItem(uint _itemId) public view returns(Item memory){
        require(items[_itemId].price > 0, "Item doesn't exist");
        return items[_itemId];
    }

    function setItem(uint _itemId, uint _price) public {
        require(items[_itemId].price > 0, "Item doesn't exist");
        require(_price > 0);
        items[_itemId].price = _price;
    }

    function deleteItem(uint _itemId) public {
        require(items[_itemId].price > 0, "Item doesn't exist");
        delete items[_itemId];
    }

    function totalItems() public view returns(uint){
        return items.length;
    }

    event newItem(string name, uint price, uint units);
}
