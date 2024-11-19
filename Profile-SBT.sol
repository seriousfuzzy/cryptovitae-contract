// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IExternalNFT is IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract CryptoVitaeProfileSBT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    IExternalNFT public accessControlNFT; // Contrato de NFT de control de acceso

    mapping(uint256 => string) private _tokenURIs;

    constructor(address _accessControlNFT)
        ERC721("CryptoVitaeProfileSBT", "CVP")
        Ownable(msg.sender)
    {
        accessControlNFT = IExternalNFT(_accessControlNFT);
    }

    // Sobrescribe la función tokenURI para agregar la lógica de verificación
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

        // Verifica si el solicitante tiene un NFT del contrato de control de acceso o es el propietario del token
        require(
            hasAccess(msg.sender) || ownerOf(tokenId) == msg.sender,
            "Access restricted: you must own an NFT from the access control contract or own this SBT"
        );

        return _tokenURIs[tokenId];
    }

    // Función para verificar si una dirección tiene un NFT del contrato de control de acceso
    function hasAccess(address _address) public view returns (bool) {
        return accessControlNFT.balanceOf(_address) > 0;
    }

    // Función para verificar si una dirección ya posee un SBT en este contrato
    function hasProfileSBT(address _address) public view returns (bool) {
        return balanceOf(_address) > 0;
    }

    // Función para acuñar un nuevo SBT
    function createSBT(string memory _tokenURI) public returns (uint256) {
        require(bytes(_tokenURI).length > 0, "Token URI is required");
        require(
            !hasProfileSBT(msg.sender),
            "Address already owns a profile SBT"
        );

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        _tokenURIs[tokenId] = _tokenURI;
    }

    // Función interna para manejar la actualización de transferencias de tokens (Soulbound)
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721) returns (address) {
        address from = _ownerOf(tokenId);
        if (from == address(0)) {
            return super._update(to, tokenId, auth);
        }
        if (from != address(0) && (to != address(0))) {
            revert("Soulbound: Transfer failed");
        }

        return super._update(to, tokenId, auth);
    }
}
