pragma solidity 0.8.7;
 
import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Storage.sol";
 
contract TestSimpleStorage {
 
 function testItStoresAValue() public {
   Storage storage = Storage(DeployedAddresses.Storage());
   storage.store(89);
   uint expected = 89;
   Assert.equal(storage.retrieve(), expected, "It should store the value 89.");
 }
}


// Lanch the test : truffle test test/TestStorage.sol --network develop