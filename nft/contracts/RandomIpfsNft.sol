// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

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
contract RandomIpfsNft is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface private immutable vrfCoordinator;

    constructor(address vrfCoordinatorV2) VRFConsumerBaseV2(vrfCoordinatorV2) {
        vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        
    }

}