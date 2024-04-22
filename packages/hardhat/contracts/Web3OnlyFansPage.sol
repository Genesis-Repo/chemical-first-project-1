// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Web3OnlyFansPage is Ownable, ERC721Enumerable {
    string private _baseTokenURI;
    
    mapping(uint256 => address) private _tokenCreators;
    mapping(address => bool) private _approvedCreators;

    event TokenCreated(address indexed creator, uint256 tokenId);

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

    function tokenCreator(uint256 tokenId) public view returns(address) {
        return _tokenCreators[tokenId];
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
}