// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./Allowable.sol";
import "./IOttoMarketplace.sol";

contract OttoStorage is Ownable, IOttoMarketplace { 
    Allowable private access;

    constructor(address _allowable, address _wallet) {
      access = Allowable(_allowable);
      otto = _wallet;
    }

    modifier isAllowed {
      require(access.hasAccess(msg.sender));
      _;
    }
    
    //Token URIs
    mapping (bytes32 => string) private tokenURIs;    

    function setTokenUri(bytes32 _tokenCreator, string memory _tokenURI) public isAllowed {
      tokenURIs[_tokenCreator] = _tokenURI; 
    }     
    
    function getTokenUri(bytes32 _tokenCreator) public view isAllowed returns (string memory) { 
      return(tokenURIs[_tokenCreator]); 
    } 
    
    //Token Ids
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    function currentTokenId () public view isAllowed returns (uint256 _amount) {
      return tokenIds.current();
    }

    function nextTokenId() public isAllowed returns (uint256 _amount) {
      tokenIds.increment();
      return tokenIds.current();
    }

    //Items Sold
    Counters.Counter private itemsSold;
    
    function getItemsSold() public view isAllowed returns (uint256 _amount) {
      return itemsSold.current();
    }

    function anotherSold() public isAllowed {
      itemsSold.increment();
    }

    // Listing Price
    uint256 private listingPrice = 0.025 ether;    
    
    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner {
      listingPrice = _listingPrice;
    }

    function getListingPrice() public view isAllowed returns (uint256 _listingPrice) {
      return listingPrice;
    }

    // Otto Share
    uint96 private ottoShare = 3;
    
    function getOttoShare() public view isAllowed returns (uint96 _ottoShare){
      return ottoShare;
    }

    function setOttoShare(uint96 _share) public onlyOwner {
      ottoShare = _share;
    }

    // Otto Wallet
    address private otto;
    
    function getOttoWallet() public view isAllowed returns (address _otto) {
      return otto;
    }

    // Token Sellers
    bytes32[] private tokenCreators;
    
    function addTokenCreator(bytes32 _seller) public isAllowed {
      tokenCreators.push(_seller);
    }

    function getTokenCreators() public view isAllowed returns (bytes32[] memory _addresses) {
      return tokenCreators;
    }

    mapping(bytes32 => MarketItem) private marketItems;
    
    function setMarketItem (bytes32 _seller, MarketItem memory _item) public isAllowed {
      marketItems[_seller] = _item;
    }

    function getMarketItem (bytes32 _sellerId) public view isAllowed returns (MarketItem memory _item)
    {
      return (marketItems[_sellerId]);
    }

    /* Returns all unsold market items */
    function fetchAllItems() public view isAllowed returns (MarketItem[] memory _items) 
    {
      uint256 currentIndex = 0;
      uint256 totalTokens = 0;
      
      for (uint i = 0; i < tokenCreators.length; i++){
        totalTokens += 1;
      }

      _items = new MarketItem[](totalTokens);
      
      for (uint i = 0; i < totalTokens; i++) {
        MarketItem storage currentItem = marketItems[tokenCreators[i]];

          _items[currentIndex] = currentItem;
        currentIndex += 1;
      }
      return (_items);
    }

    /* Returns all unsold market items */
    function fetchMarketItems(address market) public view isAllowed returns (MarketItem[] memory _items) 
    {
      uint256 currentIndex = 0;
      uint256 totalTokens = 0;
      
      for (uint i = 0; i < tokenCreators.length; i++) {
        if (marketItems[tokenCreators[i]].owner == market) {
          totalTokens += 1;
        }
      }

      _items = new MarketItem[](totalTokens);

      for (uint i = 0; i < tokenCreators.length; i++) {
        if (marketItems[tokenCreators[i]].owner == market) {
          MarketItem storage currentItem = marketItems[tokenCreators[i]];

          _items[currentIndex] = currentItem;

          currentIndex += 1;
        }
      }

      return (_items);
    }

    /* Returns only items that a user has purchased */
    function fetchMyNFTs(address sender) public view isAllowed returns (MarketItem[] memory _items) 
    {
      uint totalTokens = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < tokenCreators.length; i++) {
        if (marketItems[tokenCreators[i]].owner == sender) {
          totalTokens += 1;
        }
      }

      _items = new MarketItem[](totalTokens);

      for (uint i = 0; i < tokenCreators.length; i++) {
        if (marketItems[tokenCreators[i]].owner == sender) {
          MarketItem storage currentItem = marketItems[tokenCreators[i]];

          _items[currentIndex] = currentItem;

          currentIndex += 1;
        }
      }

      return (_items);
    }

    /* Returns only items a user has listed */
    function fetchItemsListed(address sender) public view isAllowed returns (MarketItem[] memory _items) 
    {
      uint totalTokens = 0;
      uint currentIndex = 0;

      for (uint i = 0; i < tokenCreators.length; i++) {
        if (marketItems[tokenCreators[i]].seller == sender && marketItems[tokenCreators[i]].sold < marketItems[tokenCreators[i]].amount) {
          totalTokens += 1;
        }
      }

      _items = new MarketItem[](totalTokens);

      for (uint i = 0; i < tokenCreators.length; i++) {
        if (marketItems[tokenCreators[i]].seller == sender && marketItems[tokenCreators[i]].sold < marketItems[tokenCreators[i]].amount) {
          MarketItem storage currentItem = marketItems[tokenCreators[i]];

          _items[currentIndex] = currentItem;

          currentIndex += 1;
        }
      }
      return (_items);
    }
}