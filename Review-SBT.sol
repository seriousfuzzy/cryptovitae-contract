// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IExternalNFT is IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract CryptoVitaeReviewSBT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    IExternalNFT public externalNFTContract;

    enum Visibility { Private, Public }

    struct Review {
        Visibility visibility;
        uint256 companyNFTId;
    }

    // Mapeo para almacenar la tokenURI de cada token
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => Review) private _reviews;
    mapping(address => uint256[]) private _reviewsByEmployee;

    constructor(address _externalNFTContract) 
        ERC721("CryptoVitaeReviewSBT", "CVR")
        Ownable(msg.sender)
    {
        externalNFTContract = IExternalNFT(_externalNFTContract);
    }

    modifier onlyNFTHolder(uint256 nftId) {
        require(externalNFTContract.ownerOf(nftId) == msg.sender, "You must own the NFT from the external contract");
        _;
    }

    modifier onlyHolder(uint256 tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Not the owner of this SBT");
        _;
    }

    function createSBT(
        address employee,
        string memory tokenURI,
        uint256 companyNFTId
    ) public onlyNFTHolder(companyNFTId) returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(employee, newTokenId);

        _reviews[newTokenId] = Review({
            visibility: Visibility.Private,
            companyNFTId: companyNFTId
        });

        _reviewsByEmployee[employee].push(newTokenId);

        _setTokenURI(newTokenId, tokenURI);

        return newTokenId;
    }

    function approveSBT(uint256 tokenId) public onlyHolder(tokenId) {
        require(_reviews[tokenId].visibility == Visibility.Private, "SBT is already public");

        // Cambiar el estado a público
        _reviews[tokenId].visibility = Visibility.Public;
    }

    function getReview(uint256 tokenId) public view returns (
        string memory tokenURI,
        Visibility visibility,
        uint256 companyNFTId
    ) {
        Review memory review = _reviews[tokenId];
        require(review.visibility == Visibility.Public || ownerOf(tokenId) == msg.sender, "This SBT is private");
        return (
            _tokenURIs[tokenId],
            review.visibility,
            review.companyNFTId
        );
    }

    function getReviewsByEmployee(address employee) public view returns (uint256[] memory) {
        return _reviewsByEmployee[employee];
    }

    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal {
        _tokenURIs[tokenId] = tokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        return _tokenURIs[tokenId];
    }

    // // Bloquear transferencia en `transferFrom`
    // function transferFrom(address from, address to, uint256 tokenId) public override {
    //     revert("This SBT is non-transferable");
    // }

    // // Bloquear transferencia en `safeTransferFrom`
    // function safeTransferFrom(address from, address to, uint256 tokenId) public override {
    //     revert("This SBT is non-transferable");
    // }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        revert("This SBT is non-transferable");
    }
}
