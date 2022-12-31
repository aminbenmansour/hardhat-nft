const { network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { storeImages, storeTokenUriMetadata } = require("../utils/uploadToPinata")
const { verify } = require("../utils/verify")

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
        tokenURIs,
        networkConfig[chainId].mintFee,
    ]

    const randomIpfsNft = await deploy("RandomIpfsNft", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1
    })
    log("--------------------------")
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying ...")
        await verify(randomIpfsNft.address, args)
    }
}

async function handleTokenURIs() {
    tokenURIs = []
    // Store image and metadata in IPFS
    const { responses: imageUploadResponses, files } = await storeImages(imagesLocation)
    for(imageUploadResponseIndex in imageUploadResponses) {
        // create metadata
        // upload the metadata
        let tokenURIsMetadata = {...metadataTemplate}
        tokenURIsMetadata.name = files[imageUploadResponseIndex].replace(".png", "")
        tokenURIsMetadata.description = `An adorable ${tokenURIsMetadata.name} pup!`
        tokenURIsMetadata.image = `ipfs://${imageUploadResponses[imageUploadResponseIndex].IpfsHash}`
        
        console.log(`Uploading ${tokenURIsMetadata.name}...`)
        // Store JSON to IPFS through Pinata
        const metadataUploadResponse = await storeTokenUriMetadata(tokenURIsMetadata)
        tokenURIs.push(`ipfs://${metadataUploadResponse.IpfsHash}`)
    }

    console.log("Token URIs Uploaded! They are:")
    console.log(tokenURIs)
    return tokenURIs
}

module.exports.tags = ["all", "main", "randomipfs"]