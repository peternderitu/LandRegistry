pragma solidity ^0.6.0;

import './propertyownership.sol';

contract PropertyTransactions is PropertyOwnership {
    // struct that contains properties that are to be leased or rented
    struct rentedProperty {
        //original owner and lender of the property
        address payable lessor;
        // the renter
        address lessee;
        uint tokenId;
        bool isLeased;
        uint startLease;
        uint endLease;
        uint leasePeriodinseconds;
        uint leaseFee;
    }
    
    
    //property value or cost of a property
    uint value;
    

    mapping(uint => rentedProperty) public propertyAvailableToLease;
    mapping (uint => uint) public propertyIdToValue;
    
    
  
  
   function enablePropertyForLeasing(uint _propertyId, uint _leasePeriodinseconds, uint _leaseFee, address to) public onlyOwner returns(bool) {
       require(_leasePeriodinseconds > 0, "Must have leasePeriod");
       require(_leaseFee > 0, "Must have leaseFee");
       require(_propertyId == ownerToToken[msg.sender]);
       propertyAvailableToLease[_propertyId] = rentedProperty({
           lessor: msg.sender,
           lessee: to,
           tokenId: ownerToToken[msg.sender],
           isLeased: false,
           startLease: 0,
           endLease:0,
           leasePeriodinseconds: _leasePeriodinseconds,
           leaseFee: _leaseFee
       });
       
       return true;
   }
    
    function _valuateProperty(address _owner, uint _propertyId, uint _value) onlyValidator(msg.sender) public returns(uint) {
        _propertyId = ownerToToken[_owner];
        propertyIdToValue[_propertyId]+=_value;
        return(propertyIdToValue[_propertyId]);
    }
    
    function leaseProperty(uint _propertyId, address to) public payable returns(bool) {
        ownerToToken[msg.sender]=_propertyId;
        rentedProperty storage rentP = propertyAvailableToLease[_propertyId];
        require(msg.value == rentP.leaseFee);
        require(rentP.isLeased != true);
        
        rentP.lessee = to;
        rentP.isLeased = true;
        
        rentP.startLease = now;
        rentP.endLease = now + rentP.leasePeriodinseconds;
        
        transferFrom(rentP.lessor, rentP.lessee, _propertyId);
        
        return true;
    }
    function getRemainingTimeLeftForLease(uint _propertyId,address holder) public view returns(uint) {
        require(ownerToToken[holder]==_propertyId);
        rentedProperty storage rentP = propertyAvailableToLease[_propertyId];

        if (block.timestamp <= rentP.startLease) return rentP.endLease - rentP.startLease;
        if (block.timestamp > rentP.endLease) return 0;
    }
    
    // returns ownership of lease to lender
    function getBackProperty(uint _propertyId) public {
        require(ownerToToken[msg.sender]==_propertyId);
        uint timeLeft = getRemainingTimeLeftForLease(_propertyId,msg.sender);
        
        rentedProperty storage rentP = propertyAvailableToLease[_propertyId];
        require(msg.sender == rentP.lessor);
        if (timeLeft == 0) {
            transferFrom(rentP.lessee, rentP.lessor, _propertyId);
        }
    }
    
    function payTax(uint _propertyId) external payable  {
        require(ownerToToken[msg.sender]==_propertyId);
         // value of tax on property to be paid to the government
        uint numerator = 5 * _valuateProperty(msg.sender,_propertyId,value);
        uint denominator = 100;
        uint stampduty = numerator /  denominator;
        require(msg.value == stampduty);
        govtaddress.transfer(msg.value);
    }
    
   
}
