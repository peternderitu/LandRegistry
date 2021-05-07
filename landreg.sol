pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/access/Ownable.sol';

//SPDX-License-Identifier: UNLICENSED
contract LandReg is Ownable {
    uint holdercount = 0;
    enum State {ApprovedForTransaction, Sold, Leased}
     //struct that holds property owner details which i call holder
    struct holder {
        string name;
        string tax_pin;
        string email;
        string imageHash;
        uint id_no;
        uint contact;
        address _address;
        bool isExist;
    }
   
    //struct that holds validator details, they are responsible for valuating property for tax purposes
    struct validator {
        string name;
        string title;
        string email;
        uint id_no;
        address addr;
        bool isExist;
    }
     //struct that holds property details
    struct property {
        string name;
        string location;
        string holder_name;
        string lr_no;
        string ipfsHash;
        string landimgipfshash;
        uint holder_id;
        address _addr;
    }
    address public ceoaddress;
    address payable govtaddress;
    
    modifier onlyCEO() {
        require(msg.sender == ceoaddress);
        _;
    }
 
    // array for storing properties
    property[] public properties;
    //array for storing holders
    holder [] public holders;
    
 
    //event that listens to addition of a new property into the properties array
    event NewProperty(uint propertyId, string name, string location, string holder_name, string lr_no, string ipfsHash, string landimgipfshash);
    event LogApprovedForTransaction(uint propertyId);
    event LogSold(uint propertyId);
    event LogLeased(uint propertyId);
    
    
    // a lookup of how many properties a holder has
    mapping (address => uint) public holderToPropertyCount;
    // a lookup of property owners by their property id
    mapping (uint => address) public propertyToHolder;
    // a lookup of validatorDetails by their addresses
    mapping (address => validator) validatorDetails;
    mapping (address => property) public publicProperty;
    mapping (address => holder) public holderdetails;
  
    
    
    // function that registers holders
    function regHolders(string memory name, string memory tax_pin, string memory email,string memory imageHash, uint id_no, uint contact) public {
        holders.push(holder(name,tax_pin,email,imageHash, id_no,contact,msg.sender,true));
        holderdetails[msg.sender]=holder(name,tax_pin,email,imageHash, id_no,contact,msg.sender,true);
    }

    //function that returns holder details
    function getHolders() public view returns (holder[] memory){
        return holders;
    }
    
    // function that registers validators 
    function regValidators(string memory name, string memory title,string memory email, uint id_no) public onlyCEO {
        
        // check if validator exist already
        validatorDetails[msg.sender]=validator(name,title,email,id_no,msg.sender,true);
    }
    
    // function that returns validator details by address
     function getvalidatorDetails(address addr) public view returns (string memory,string memory,string memory,uint,address){
        
        return(validatorDetails[addr].name,validatorDetails[addr].title, validatorDetails[addr].email,validatorDetails[addr].id_no,validatorDetails[addr].addr);
    }
    //function that registers property by their owners
    function regProperty(string memory name, string memory location, string memory holder_name, string memory lr_no,string memory ipfsHash, string memory landimgipfshash, uint holder_id) public onlyOwner() {
        require(holderdetails[msg.sender].isExist==true);
        //push each property to the properties array
        properties.push(property(name, location, holder_name, lr_no, ipfsHash,landimgipfshash, holder_id, msg.sender));
        
        // get property id by array length
        uint id = properties.length - 1;
        propertyToHolder[id] = msg.sender;
         
        // add property count
        holderToPropertyCount[msg.sender]++;
        emit NewProperty(id, name, location, holder_name, lr_no, ipfsHash, landimgipfshash);
        //sort the properties to obtain property owned by govt address and store them in publicProperty mapping
        if(propertyToHolder[id] == govtaddress){
            publicProperty[govtaddress] = property(name,location,holder_name,lr_no,ipfsHash,landimgipfshash, holder_id,msg.sender);
        }
    }
    //function that returns property details
    function getProperties() public view returns (property[] memory){
        return properties;
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
    // fubnction to get all public properties from the publicProperty mapping
     function getPublicProperty() public view returns (string memory,string memory,string memory, string memory,string memory,uint){
        
        return(publicProperty[govtaddress].name,publicProperty[govtaddress].location,publicProperty[govtaddress].holder_name,publicProperty[govtaddress].lr_no,publicProperty[govtaddress].ipfsHash,publicProperty[govtaddress].holder_id);
    }
    
}
