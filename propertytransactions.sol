pragma solidity ^0.6.0;

import './propertyownership.sol';

contract PropertyTransactions is PropertyOwnership {
    
    uint stampduty = 5;
    uint leasePeriod;
    uint leaseFee;
    uint value;
    
    mapping (uint => address) subdivisionAllowedToAddress;
    
    modifier onlyValidator() {
        require (msg.sender == validatorDetails[addr].addr);
        _;
    }
   // function withdraw() external onlyOwner {
   //     address _owner = owner();
   //     _owner.transfer(address(this).balance);
   //   }
    function setLeasePeriod(uint _months) external {
        leasePeriod = (now + _months) - now;
    }

    function setLeaseFee(uint _fee) external onlyOwner {
        leaseFee = _fee * leasePeriod;
    }
    
    function _valuateProperty(uint _value) onlyValidator() internal {
       value = _value; 
    }
    function leaseProperty(uint _propertyId) public payable {
        require(msg.value == leaseFee);
        if (leasePeriod > 0){
        transferFrom(owner(), msg.sender, _propertyId);
        } else {
            renewLease(_propertyId);
        }
    }
    function renewLease(uint _propertyId) public {
        leaseProperty(_propertyId);
    }
    function payTax(uint _tax) external payable onlyOwner {
        require(msg.value == stampduty);
        
    }
}
