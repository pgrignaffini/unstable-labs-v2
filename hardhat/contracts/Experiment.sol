// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// TO DO: Explain the reason/advantadge to use ERC721URIStorage instead of ERC721 itself
contract Experiment is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address private marketplaceAddress;
    mapping(uint256 => address) private _creators;
    mapping(uint256 => string) public tokenURIs;

    struct NFTData {
        uint256 tokenId;
        string tokenURI;
    }

    event TokenMinted(
        uint256 indexed tokenId,
        string tokenURI,
        address marketplaceAddress
    );

    constructor(address _marketplaceAddress)
        ERC721("UnstableExperiments", "UEXP")
    {
        marketplaceAddress = _marketplaceAddress;
    }

    function mintToken(string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        _creators[newItemId] = msg.sender;
        _setTokenURI(newItemId, tokenURI);
        tokenURIs[newItemId] = tokenURI;

        // Give the marketplace approval to transact NFTs between users
        setApprovalForAll(marketplaceAddress, true);

        emit TokenMinted(newItemId, tokenURI, marketplaceAddress);
        return newItemId;
    }

    function getTokenIds() public view returns (uint256[] memory) {
        uint256[] memory tokenIds = new uint256[](_tokenIds.current());
        for (uint256 i = 0; i < _tokenIds.current(); i++) {
            tokenIds[i] = i + 1;
        }
        return tokenIds;
    }

    function getTokenURI(uint256 tokenId) public view returns (NFTData memory) {
        return NFTData(tokenId, tokenURIs[tokenId]);
    }

    function getTokenURIs(uint256[] memory tokenIds)
        public
        view
        returns (NFTData[] memory)
    {
        NFTData[] memory uris = new NFTData[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uris[i] = NFTData(tokenIds[i], tokenURIs[tokenIds[i]]);
        }
        return uris;
    }

    function getTokensOwnedByMe() public view returns (uint256[] memory) {
        uint256 numberOfExistingTokens = _tokenIds.current();
        uint256 numberOfTokensOwned = balanceOf(msg.sender);
        uint256[] memory ownedTokenIds = new uint256[](numberOfTokensOwned);

        uint256 currentIndex = 0;
        for (uint256 i = 0; i < numberOfExistingTokens; i++) {
            uint256 tokenId = i + 1;
            if (ownerOf(tokenId) != msg.sender) continue;
            ownedTokenIds[currentIndex] = tokenId;
            currentIndex += 1;
        }

        return ownedTokenIds;
    }

    function getTokenCreatorById(uint256 tokenId)
        public
        view
        returns (address)
    {
        return _creators[tokenId];
    }

    function getTokensCreatedByMe() public view returns (uint256[] memory) {
        uint256 numberOfExistingTokens = _tokenIds.current();
        uint256 numberOfTokensCreated = 0;

        for (uint256 i = 0; i < numberOfExistingTokens; i++) {
            uint256 tokenId = i + 1;
            if (_creators[tokenId] != msg.sender) continue;
            numberOfTokensCreated += 1;
        }

        uint256[] memory createdTokenIds = new uint256[](numberOfTokensCreated);
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < numberOfExistingTokens; i++) {
            uint256 tokenId = i + 1;
            if (_creators[tokenId] != msg.sender) continue;
            createdTokenIds[currentIndex] = tokenId;
            currentIndex += 1;
        }

        return createdTokenIds;
    }
}
