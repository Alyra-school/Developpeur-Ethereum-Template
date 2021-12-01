pragma solidity 0.8.9;

/** @notice Exercice - type de visibilité des fonctions
    @author Loïs L. */
contract HelloWorld {
   string myString = "Hello World !";
  
   function hello() public view returns(string memory) {
       return myString;
   }
}