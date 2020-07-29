contract PropertyTransactions is PropertyOwnership {
    
    uint stampduty = 0.04 * value;
    modifier onlyValidator() {
        require (msg.sender == validator);
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
    function leaseProperty(uint _propertyId) external payable {
        require(msg.value == leaseFee);
        if (leasePeriod > 0){
        transferFrom(holder, msg.sender, _propertyId);
        } else {
            renewLease(_propertyId);
        }
    }
    function renewLease(uint _propertyId) external {
        leaseProperty(_propertyId);
    }
    function payTax(uint _tax) external payable onlyOwner {
        require(msg.value == stampduty);
        
    }
}