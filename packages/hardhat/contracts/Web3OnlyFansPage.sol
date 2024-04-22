// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Web3OnlyFansPage is Ownable, ERC721Enumerable {
    string private _baseTokenURI;
    
    mapping(uint256 => address) private _tokenCreators;
    mapping(address => bool) private _approvedCreators;
    mapping(uint256 => bool) private _tokenSubscribers;
    mapping(uint256 => string) private _tokenContent;

    event TokenCreated(address indexed creator, uint256 tokenId);
    event Subscription(address indexed subscriber, uint256 tokenId);
    event ContentUploaded(uint256 indexed tokenId, string content);

    constructor(string memory name, string memory symbol, string memory baseTokenURI_) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI_;
    }

    function setBaseTokenURI(string memory baseTokenURI_) external onlyOwner {
        _baseTokenURI = baseTokenURI_;
    }

    function createToken() external {
        require(_approvedCreators[msg.sender], "Creator not approved");
        
        uint256 tokenId = totalSupply() + 1;
        _mint(msg.sender, tokenId);
        _tokenCreators[tokenId] = msg.sender;

        emit TokenCreated(msg.sender, tokenId);
    }

    function approveCreator(address creator) external onlyOwner {
        _approvedCreators[creator] = true;
    }

    function revokeCreator(address creator) external onlyOwner {
        _approvedCreators[creator] = false;
    }

    function subscribe(uint256 tokenId) external {
        require(_exists(tokenId), "Token does not exist");
        _tokenSubscribers[tokenId] = true;

        emit Subscription(msg.sender, tokenId);
    }

    function uploadContent(uint256 tokenId, string memory content) external {
        require(ownerOf(tokenId) == msg.sender, "Only token owner can upload content");
        _tokenContent[tokenId] = content;

        emit ContentUploaded(tokenId, content);
    }

    function getContent(uint256 tokenId) public view returns(string memory) {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender || _tokenSubscribers[tokenId], "Unauthorized to view content");
        
        return _tokenContent[tokenId];
    }

    function isSubscriber(uint256 tokenId) public view returns(bool) {
        return _tokenSubscribers[tokenId];
    }

    function tokenCreator(uint256 tokenId) public view returns(address) {
        return _tokenCreators[tokenId];
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}