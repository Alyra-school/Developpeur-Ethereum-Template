pragma solidity 0.8.9;

contract struct2 {
    struct Item{
        uint price;
        uint units;
    }
    mapping (uint => Item) itemIdToItem;
    uint itemCount;

    constructor(){
        itemCount = 0;
    }

    function addItem(uint _price, uint _units) public {
        require(_price > 0);
        require(_units > 0);
        itemIdToItem[itemCount] = Item(_price, _units);
        itemCount++;
        
        emit newItem(itemCount - 1, _price, _units);
    }

    function getItem(uint _itemId) public view returns(Item memory){
        require(_itemId < itemCount, "Item doesn't exist");
        return itemIdToItem[_itemId];
    }

    function setItem(uint _itemId, uint _price) public {
        require(_itemId < itemCount, "Item doesn't exist");
        require(_price > 0);
        itemIdToItem[_itemId].price = _price;
    }

    event newItem(uint itemId, uint price, uint units);
}
