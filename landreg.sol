pragma solidity ^0.6.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol';

contract LandReg is Ownable {
    //struct that holds property details
    struct property {
        string name;
        string location;
        string holder_name;
        string lr_no;
    }
     //struct that holds property owner details which i call holder
    struct holder {
        string name;
        string contact;
        string tax_pin;
        uint id;
        address _address;
    }
    //struct that holds validator details, they are responsible for valuating property for tax purposes
    struct validator {
        string name;
        string title;
        uint id_no;
        address addr;
        bool isExist;
    }
 
    // array for storing properties
    property[] public properties;
    // array for storing property owners
    holder[] public holders;
 
    //event that listens to addition of a new property into the properties array
    event NewProperty(uint propertyId, string name, string location, string holder_name, string lr_no);
    
    // a lookup of how many properties a holder has
    mapping (address => uint) public holderToPropertyCount;
    // a lookup of property owners by their property id
    mapping (uint => address) propertyToHolder;
    // a lookup of validatorDetails by their addresses
    mapping (address => validator) validatorDetails;
    
    // function that registers validators 
    function regValidators(string memory name, string memory title, uint id_no, address addr) public {
        
        // check if validator exist already
        require(validatorDetails[addr].isExist==false,"validator already registered");
        validatorDetails[addr]=validator(name,title,id_no,addr,true);
    }
    
    // function that returns validator details by address
     function getvalidatorDetails(address addr) public view returns (string memory,string memory,uint,address){
        
        return(validatorDetails[addr].name,validatorDetails[addr].title,validatorDetails[addr].id_no,validatorDetails[addr].addr);
    }
    //function that registers property by their owners
    function regProperty(string memory name, string memory location, string memory holder_name, string memory lr_no) public onlyOwner() {
        //push each property to the properties array
        properties.push(property(name, location, holder_name, lr_no));
        
        // get property id by array length
        uint id = properties.length - 1;
        propertyToHolder[id] = msg.sender;
        
        // add property count
        holderToPropertyCount[msg.sender] = holderToPropertyCount[msg.sender]++;
        emit NewProperty(id, name, location, holder_name, lr_no);
    }
    
    // function that gets all properties by their owners address
    function getPropertyByHolder(address _holder) external view returns(uint[] memory) {
        uint[] memory result = new uint[] (holderToPropertyCount[_holder]);
        uint counter = 0;
        
        //loops throught the holders array checking each holder and the properties they own and adds a counter for each property a holder has
        for (uint i = 0; i < holders.length; i++) {
            if(propertyToHolder[i] == _holder) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    
}
