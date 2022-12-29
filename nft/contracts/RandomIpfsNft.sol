// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

pragma solidity ^0.8.7;

/**
 * @notice Minitng an NFT will trigger a ChainlinkVRF call to get a random number
 * @notice Using that number, we will get a random NFT
 *          Pug, Shiba Inu, St. Bernard:
 *              Pug: Super rare
 *              Shiba Inu; Rare
 *              St. Bernard: common
 * @notice Users have to pay to mint an NFT
 * @notice The owner of the contract can withdraw the ETH
 * 
 */
contract RandomIpfsNft is ERC721 {
    constructor() {

    }
}