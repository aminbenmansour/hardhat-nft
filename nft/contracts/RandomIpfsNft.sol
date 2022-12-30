// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

pragma solidity ^0.8.7;

error RandomIpfsNft__RangeOutOdBounds();
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
contract RandomIpfsNft is ERC721, VRFConsumerBaseV2 {
    
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }
    // Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable vrfCoordinator;
    uint64 private immutable subscriptionId;
    bytes32 private immutable gasLane;
    uint32 private immutable callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // VRF helpers
    mapping(uint256 => address) public requestIdToSender; 

    // NFT VARiables
    uint256 public tokenCounter;
    uint256 internal constant MAX_CHANCE_VALUE = 100;

    constructor(
        address vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random IPFS NFT", "RIN") {
        vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        subscriptionId = _subscriptionId;
        gasLane = _gasLane;
        callbackGasLimit = _callbackGasLimit;
    }

    function requestNft() public returns (uint256 requestId) {
        requestId = vrfCoordinator.requestRandomWords(
            gasLane,
            subscriptionId,
            REQUEST_CONFIRMATIONS,
            callbackGasLimit,
            NUM_WORDS
        );

        requestIdToSender[requestId] = msg.sender;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address dogOwner = requestIdToSender[requestId];
        uint256 newTokenId = tokenCounter;
        
        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE; // number between 0 and 99

        // [0-9] -> PUG
        // [10 - 39] -> Shiba Inu
        // [40-99] -> St. Bernard

        Breed dogBreed = getBreedFromModdedRng(moddedRng);
        _safeMint(dogOwner, newTokenId);

    }

    function getBreedFromModdedRng(uint256 moddedRng)  public pure returns (Breed) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();

        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (moddedRng >= cumulativeSum && moddedRng < cumulativeSum + chanceArray[i]) {
                return Breed(i);
            }
            cumulativeSum += chanceArray[i];
        }
        revert RandomIpfsNft__RangeOutOdBounds();
    }
    function getChanceArray() public pure returns(uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }

}