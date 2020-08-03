pragma solidity ^0.6.0;

import './propertyownership.sol';

contract PropertyTransactions is PropertyOwnership {
    
    struct rentedProperty {
        address payable lessor;
        address lessee;
        uint tokenId;
        bool isLeased;
        uint startLease;
        uint endLease;
        uint leasePeriod;
        uint leaseFee;
    }
    
    uint stampduty = 5;
    uint value;
    mapping(uint => rentedProperty) public propertyAvailableToLease;
    mapping (uint => address) subdivisionAllowedToAddress;
    
    modifier onlyValidator(address addr) {
        require (msg.sender == validatorDetails[addr].addr);
        _;
    }
  
   function enablePropertyForLeasing(uint _propertyId, uint _leasePeriod, uint _leaseFee) public onlyOwner returns(bool) {
       require(_leasePeriod > 0, "Must have leasePeriod");
       require(_leaseFee > 0, "Must have leaseFee");
       
       propertyAvailableToLease[_propertyId] = rentedProperty({
           lessor: msg.sender,
           lessee: address(0x0),
           tokenId: _propertyId,
           isLeased: false,
           startLease: 0,
           endLease:0,
           leasePeriod: _leasePeriod,
           leaseFee: _leaseFee
       });
       
       return true;
   }
    
    function _valuateProperty(uint _value) onlyValidator(msg.sender) internal {
       value = _value; 
    }
    function leaseProperty(uint _propertyId) public payable returns(bool) {
        rentedProperty storage rentP = propertyAvailableToLease[_propertyId];
        require(msg.value == rentP.leaseFee);
        require(rentP.isLeased != true);
        require(rentP.lessee == address(0));
        
        rentP.lessee = msg.sender;
        rentP.isLeased = true;
        
        rentP.startLease = now;
        rentP.endLease = now + rentP.leasePeriod;
        
        transferFrom(msg.sender, address(this), rentP.leaseFee);
        transferFrom(rentP.lessor, msg.sender, _propertyId);
        
        return true;
    }
    function getRemainingTimeLeftForLease(uint _propertyId) public view returns(uint) {

        rentedProperty storage rentP = propertyAvailableToLease[_propertyId];

        if (block.timestamp <= rentP.startLease) return rentP.endLease - rentP.startLease;
        if (block.timestamp > rentP.endLease) return 0;
    }
    function getBackProperty(uint _propertyId) public {
        uint timeLeft = getRemainingTimeLeftForLease(_propertyId);
        
        rentedProperty storage rentP = propertyAvailableToLease[_propertyId];
        require(msg.sender == rentP.lessor);
        if (timeLeft == 0) {
            transferFrom(rentP.lessee, rentP.lessor, _propertyId);
        }
    }
    
    function payTax() external payable onlyOwner {
        require(msg.value == stampduty);
        
    }
    function withdraw(uint _propertyId) external onlyOwner {
        rentedProperty storage rentP = propertyAvailableToLease[_propertyId];
        address payable _owner = rentP.lessor;
        _owner.transfer(address(this).balance);
      }
}
