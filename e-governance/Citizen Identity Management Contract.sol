// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CitizenIdentity {
    struct Citizen {
        string name;
        uint256 nationalId;
        bool isVerified;
        address citizenAddress;
        uint256 registrationDate;
    }
    
    mapping(address => Citizen) public citizens;
    address public government;
    
    event CitizenRegistered(address indexed citizenAddress, string name);
    event CitizenVerified(address indexed citizenAddress);
    
    constructor() {
        government = msg.sender;
    }
    
    modifier onlyGovernment() {
        require(msg.sender == government, "Only government can perform this action");
        _;
    }
    
    function registerCitizen(string memory _name, uint256 _nationalId) public {
        require(citizens[msg.sender].citizenAddress == address(0), "Citizen already registered");
        
        citizens[msg.sender] = Citizen({
            name: _name,
            nationalId: _nationalId,
            isVerified: false,
            citizenAddress: msg.sender,
            registrationDate: block.timestamp
        });
        
        emit CitizenRegistered(msg.sender, _name);
    }
    
    function verifyCitizen(address _citizenAddress) public onlyGovernment {
        require(citizens[_citizenAddress].citizenAddress != address(0), "Citizen not registered");
        citizens[_citizenAddress].isVerified = true;
        emit CitizenVerified(_citizenAddress);
    }
    
    function isCitizenVerified(address _citizenAddress) public view returns (bool) {
        return citizens[_citizenAddress].isVerified;
    }
}