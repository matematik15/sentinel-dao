const ethers = require("ethers")
const { Framework } = require("@superfluid-finance/sdk-core")

const url = process.env.GOERLI_URL

const customHttpProvider = new ethers.providers.JsonRpcProvider(url)

async function main() {
    const network = await customHttpProvider.getNetwork()

    const sf = await Framework.create({
        chainId: network.chainId,
        provider: customHttpProvider
    })

    const deployer = sf.createSigner({
        privateKey: process.env.DEPLOYER_PRIVATE_KEY,
        provider: customHttpProvider
    })

    console.log("running deploy script...")

    const PIC = await hre.ethers.getContractFactory("PIC")
    const pIC = await PIC.connect(deployer).deploy("0x8ae68021f6170e5a766be613cea0d75236ecca9a", "0xa54FC15FC75693447d70a57262F37a70B614721b")

    await pIC.deployed()

    console.log("PIC.sol deployed to:", pIC.address)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })