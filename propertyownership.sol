pragma solidity ^0.6.0;

import './landreg.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';

contract PropertyOwnership is LandReg, ERC721 {
    
    constructor() ERC721("TitleDeed", "TD") public { }
    
    mapping (uint => address) propertyApprovals;
    
    
    modifier onlyOwnerOf(uint _propertyId) {
    require(msg.sender == propertyToHolder[_propertyId]);
    _;
  }
    modifier onlyValidator(address addr) {
        require (msg.sender == validatorDetails[addr].addr);
        _;
    }
    function _owns(address _claimingaddr, uint _tokenId) internal view returns(bool) {
        return propertyToHolder[_tokenId] == _claimingaddr;
    }
    function BalanceOf(address _holder) public view returns(uint count) {
        return holderToPropertyCount[_holder];
    }
    function OwnerOf(uint _tokenId) public view  returns(address){
        return propertyToHolder[_tokenId];
    }
    function TotalSupply() public view returns (uint) {
        return properties.length - 1;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal override {
    holderToPropertyCount[_to] = holderToPropertyCount[_to].add(1);
    holderToPropertyCount[msg.sender] = holderToPropertyCount[msg.sender].sub(1);
    propertyToHolder[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

    function transferFrom(address _from, address _to, uint256 _tokenId) public override {
      require (propertyToHolder[_tokenId] == msg.sender || propertyApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public override onlyOwnerOf(_tokenId) onlyValidator(msg.sender) {
      propertyApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }
    function _approvedFor(address _claimingaddr, uint _tokenId) internal view returns(bool) {
        return propertyApprovals[_tokenId] == _claimingaddr;
    }
}
