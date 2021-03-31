pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;
import './landreg.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/token/ERC721/ERC721.sol';
//SPDX-License-Identifier: UNLICENSED
contract PropertyOwnership is LandReg, ERC721 {
    
    constructor() ERC721("TitleDeed", "TD") public { }
    
    mapping (address => uint) public propertyApprovals;
    mapping (address => uint) public ownerToToken;
    
    
    modifier onlyOwnerOf(uint _propertyId) {
    require(msg.sender == propertyToHolder[_propertyId]);
    _;
  }
    modifier onlyValidator(address addr) {
        require (msg.sender == validatorDetails[addr].addr);
        _;
    }
    function approveTokenization(address holder) internal onlyValidator(msg.sender) returns(uint){
        uint tokenid = properties.length -1;
        propertyApprovals[holder]+=tokenid;
        emit LogApprovedForTransaction(tokenid);
        return propertyApprovals[holder];
    }
    function mintToken(address owner, uint token) internal {
        _safeMint(owner,token);
    }
    function createTitle() public returns(uint){
        uint tokenId = approveTokenization(msg.sender);
        mintToken(msg.sender,tokenId);
        ownerToToken[msg.sender]+=tokenId;
        return totalSupply();
    }
    
}
