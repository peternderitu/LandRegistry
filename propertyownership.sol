pragma solidity ^0.6.0;

import './landreg.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol';

contract PropertyOwnership is LandReg, ERC721 {
    
    mapping (uint => address) propertyApprovals;
    modifier onlyOwnerOf(uint _propertyId) {
    require(msg.sender == propertyToHolder[_propertyId]);
    _;
  }
    
    function balanceOf(address _holder) external view returns(uint) {
        return holderToPropertyCount[_holder];
    }
    function ownerOf(uint _tokenId) external view returns(address){
        return propertyToHolder[_tokenId];
    }
    function _transfer(address _from, address _to, uint256 _tokenId) private {
    holderToPropertyCount[_to] = holderToPropertyCount[_to].add(1);
    holderToPropertyCount[msg.sender] = holderToPropertyCount[msg.sender].sub(1);
    propertyToHolder[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
      require (propertyToHolder[_tokenId] == msg.sender || propertyApprovals[_tokenId] == msg.sender);
      _transfer(_from, _to, _tokenId);
    }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
      propertyApprovals[_tokenId] = _approved;
      emit Approval(msg.sender, _approved, _tokenId);
    }
}