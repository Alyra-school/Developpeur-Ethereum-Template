// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract SPA is Ownable{
    struct Animal {
        string specie;
        uint size;
        uint age;
        bool isAdopted;
    }
    Animal animal;
    Animal[] animals;
    mapping(address => Animal) adoptions;
    
    event AnimalCreated(string _specie, uint _size, uint _age, bool _isAdopted);

    // Create
    function newAnimal(string memory _specie, uint _size, uint _age) public onlyOwner {
        require(keccak256(abi.encodePacked(_specie)) != keccak256(abi.encodePacked("")), "Species must not be empty");
        require(_size > 0, "Size must be superior to 0");
        require(_age > 0, "Age must be superior to 0");

        animals.push(Animal(_specie, _size, _age, false));
        uint animalId = animals.length - 1;
        
        emit AnimalCreated(
            animals[animalId].specie,
            animals[animalId].size,
            animals[animalId].age,
            animals[animalId].isAdopted
        );
    }

    // Read

    // Update

    // Remove

    
}
