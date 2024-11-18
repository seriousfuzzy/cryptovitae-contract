// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptoVitaeCompanyNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    mapping(uint256 => string) private _tokenURIs;

    constructor() ERC721("CryptoVitaeCompanyNFT", "CVC") Ownable(msg.sender) {
        tokenCounter = 0;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(
            ownerOf(tokenId) != address(0),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return _tokenURIs[tokenId];
    }

    function createNFT(string memory _tokenURI)
        public
        returns (uint256)
    {
        require(bytes(_tokenURI).length > 0, "Token URI is required");

        uint256 tokenId = tokenCounter;

        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        tokenCounter++;
        return tokenId;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }
}
