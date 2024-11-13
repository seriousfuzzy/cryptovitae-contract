// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CryptoVitaeCompanyNFT is ERC721, Ownable {
    uint256 public tokenCounter;

    struct Company {
        string companyName;
        string companyDescription;
        string imageCID;
    }

    mapping(uint256 => Company) private tokenIdToCompanyDetails;

    constructor() ERC721("CryptoVitaeCompanyNFT", "CVC") Ownable(msg.sender) {
        tokenCounter = 0;
    }

    function createNFT(
        address to, 
        string memory _companyName, 
        string memory _companyDescription, 
        string memory _imageCID
    ) 
        public 
        onlyOwner 
        returns (uint256) 
    {
        require(bytes(_companyName).length > 0, "Company name is required");
        require(bytes(_imageCID).length > 0, "Image CID is required");

        uint256 newItemId = tokenCounter;
        
        // Store the company details
        tokenIdToCompanyDetails[newItemId] = Company({
            companyName: _companyName,
            companyDescription: _companyDescription,
            imageCID: _imageCID
        });

        _safeMint(to, newItemId);
        tokenCounter++;
        return newItemId;
    }

    // Function to return the token URI
    function tokenURI(uint256 tokenId) 
        public 
        view 
        override 
        returns (string memory) 
    {
        require(ownerOf(tokenId) != address(0), "Token does not exist");
        Company memory company = tokenIdToCompanyDetails[tokenId];

        // Generate the metadata URI
        return string(abi.encodePacked(
            "data:application/json;base64,",
            base64Encode(bytes(abi.encodePacked(
                '{"name":"', company.companyName, '",',
                '"description":"', company.companyDescription, '",',
                '"image":"ipfs://', company.imageCID, '"}'
            )))
        ));
    }

    // Helper function to encode the token metadata in Base64
    function base64Encode(bytes memory data) 
        internal 
        pure 
        returns (string memory) 
    {
        bytes memory alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        bytes memory encodedData = new bytes((data.length + 2) / 3 * 4);
        for (uint i = 0; i < data.length; i += 3) {
            uint256 a = uint8(data[i]);
            uint256 b = i + 1 < data.length ? uint8(data[i + 1]) : 0;
            uint256 c = i + 2 < data.length ? uint8(data[i + 2]) : 0;

            encodedData[i / 3 * 4] = alphabet[a >> 2];
            encodedData[i / 3 * 4 + 1] = alphabet[((a & 3) << 4) | (b >> 4)];
            encodedData[i / 3 * 4 + 2] = alphabet[((b & 15) << 2) | (c >> 6)];
            encodedData[i / 3 * 4 + 3] = alphabet[c & 63];
        }

        return string(encodedData);
    }
}
