const { network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")
const { storeImages } = require("../utils/uploadToPinata")

const imagesLocation = "./images/randomNFT"

const metadataTemplate = {
    name: "",
    description: "",
    image: "",
    attributes: [
        {
            trait_type: "Cuteness",
            value: 100
        }
    ]
}

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId
    
    let tokenURIs
    let vrfCoordinatorV2Address, subscriptionId

    // get the IPFS hashes to our images
    if (process.env.UPLOAD_TO_PINATA == "true") {
        tokenURIs = await handleTokenURIs()
    }
    
    if (developmentChains.includes(network.name)) {
        const vrfCoordinatorV2Mock = await ethers.getContract("VRFCoordinatorV2Mock")
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address
        const tx = await vrfCoordinatorV2Mock.createSubscription()
        const txReceipt = await tx.wait(1)
        subscriptionId = txReceipt.events[0].args.subId
    } else {
        vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2
        subscriptionId = networkConfig[chainId].subscriptionId
    }

    log("--------------------------")
    await storeImages(imagesLocation)
    const args = [
        vrfCoordinatorV2Address,
        subscriptionId,
        networkConfig[chainId].gasLane,
        networkConfig[chainId].callbackGasLimit,
        // tokenUris
        networkConfig[chainId].mintFee,
    ]
    log("--------------------------")
}

async function handleTokenURIs() {
    tokenURIs = []

    // Store image in IPFS
    // Store metadata in IPFS
    const { responses: imageUploadResponses, files } = await storeImages(imagesLocation)
    
    return tokenURIs
}

module.exports.tags = ["all", "main", "randomipfs"]