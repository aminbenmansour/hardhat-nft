// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.7;

contract BasicNFT is ERC721 {
    uint256 private tokenCounter;

    constructor() ERC721("Dogie", "DOG") {
        tokenCounter = 0;
    }

    function mintNFT() public returns(uint256) {
        _safeMint(msg.sender, tokenCounter);
        tokenCounter = tokenCounter + 1;
        return tokenCounter;
    }

    function getTokenCounter() public view returns(uint256) {
        return tokenCounter;
    }
}