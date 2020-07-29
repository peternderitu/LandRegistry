pragma solidity ^0.6.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';

contract LandReg is Ownable {
    
    struct property {
        string name;
        string location;
        string holder_name;
        string lr_no;
    }
    struct holder {
        string name;
        string contact;
        string tax_pin;
        uint id;
        address _address;
    }
    struct validator {
        string name;
        string title;
        uint id_no;
    }
 
    
    property[] public properties;
    holder[] public holders;
    validator[] public validators;
    
    mapping (address => uint) public holderToPropertyCount;
    mapping (uint => address) propertyToHolder;
    mapping (uint => address) idToValidator;
    
    
    function regValidators(string memory _name, string memory _title, uint _id_no) public {
        validators.push(validator(_name, _title, _id_no));
    }
    
    function regProperty(string memory _name, string memory _lr_no) public onlyOwner() {
        properties.push(property(_name, _location, _holder_name, _lr_no));
    }
    function getPropertyByHolder(address _holder) external view returns(uint[] memory) {
        uint[] memory result = new uint[] (holderToPropertyCount[_holder]);
        uint counter = 0;
        for (uint i = 0; i < holders.length; i++) {
            if(propertyToHolder[i] == _holder) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    
}