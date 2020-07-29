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
        address addr;
        bool isExist;
    }
 
    
    property[] public properties;
    holder[] public holders;
 
    
    event NewProperty(uint propertyId, string name, string location, string holder_name, string lr_no);
    
    mapping (address => uint) public holderToPropertyCount;
    mapping (uint => address) propertyToHolder;
    mapping (address => validator) validatorDetails;
    
    
    function regValidators(string memory name, string memory title, uint id_no, address addr) public {
        require(validatorDetails[addr].isExist==false,"validator already registered");
        validatorDetails[addr]=validator(name,title,id_no,addr,true);
    }
     function getvalidatorDetails(address addr) public view returns (string memory,string memory,uint,address){
        
        return(validatorDetails[addr].name,validatorDetails[addr].title,validatorDetails[addr].id_no,validatorDetails[addr].addr);
    }
    
    function regProperty(string memory name, string memory location, string memory holder_name, string memory lr_no) public onlyOwner() {
        properties.push(property(name, location, holder_name, lr_no));
        uint id = properties.length - 1;
        propertyToHolder[id] = msg.sender;
        holderToPropertyCount[msg.sender] = holderToPropertyCount[msg.sender]++;
        emit NewProperty(id, name, location, holder_name, lr_no);
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
