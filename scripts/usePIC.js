const ethers = require("ethers")
const PicABI = require("../artifacts/contracts/PIC.sol/PIC.json").abi
const ERC777ABI = require("../artifacts/@openzeppelin/contracts/token/ERC777/ERC777.sol/ERC777.json").abi
const ERC20ABI = require("../artifacts/@openzeppelin/contracts/token/ERC20/ERC20.sol/ERC20.json").abi
const { Framework } = require("@superfluid-finance/sdk-core")

const PICAddress = "0xf7B2e829f13fcF11429e9923Fb9c4F452f50a12E"
const DAIxAddress = "0xF2d68898557cCb2Cf4C10c3Ef2B034b2a69DAD00"
const ETHxAddress = "0x5943f705abb6834cad767e6e4bb258bc48d9c947"
const SENTAddress = "0x6cef75D2ac140dc0bfe87B771aFA32a06C1c8976"
const url = "https://eth-goerli.g.alchemy.com/v2/539Uvv7_CQ1TlzwumfNghg2kbfXG5K41"

const customHttpProvider = new ethers.providers.JsonRpcProvider(url)

async function main() {
    const network = await customHttpProvider.getNetwork()

    const pIC = new ethers.Contract(
        PICAddress,
        PicABI,
        customHttpProvider
    )

    const daix = new ethers.Contract(
        DAIxAddress,
        ERC777ABI,
        customHttpProvider
    )

    const ethx = new ethers.Contract(
        ETHxAddress,
        ERC777ABI,
        customHttpProvider
    )

    const sent = new ethers.Contract(
        SENTAddress,
        ERC777ABI,
        customHttpProvider
    )

    const sf = await Framework.create({
        chainId: network.chainId,
        provider: customHttpProvider
    })

    const deployer = sf.createSigner({
        privateKey: process.env.DEPLOYER_PRIVATE_KEY,
        provider: customHttpProvider
    })

    const amount = ethers.utils.parseEther("5.2");
    const approveAmount = ethers.utils.parseEther("362") + ethers.utils.parseEther("362");
    const redeemAmount = ethers.utils.parseEther("11");
    const stakeAmount = ethers.utils.parseEther("5.2");
    const sendAmount = ethers.utils.parseEther("20");
    const ethxstakeAmount = ethers.utils.parseEther("1.1");

    // await daix.connect(deployer).approve(PICAddress, approveAmount).then(tx => {
    //     console.log(tx)
    // });

    // await pIC.connect(deployer).fundPIC(amount).then(tx => {
    //     console.log(tx)
    // });

    // await pIC.connect(deployer).becomePIC(stakeAmount, "0x0000000000000000000000000000000000000000000000000000000000000000").then(tx => {
    //     console.log(tx)
    // });

    // await pIC.connect(deployer).redeemPICStake().then(tx => {
    //     console.log(tx)
    // });

    // await pIC.connect(deployer).redeemFunds(redeemAmount).then(tx => {
    //     console.log(tx)
    // });

    // await pIC.connect(deployer).withdrawFromCustody().then(tx => {
    //     console.log(tx)
    // });

    //make the EOA PIC:
    // await daix.connect(deployer).send("0xa54FC15FC75693447d70a57262F37a70B614721b",stakeAmount,"0x0000000000000000000000000000000000000000000000000000000000000000").then(tx => {
    //     console.log(tx)
    // });

    // await pIC.connect(deployer).simulateLiquidationsRewards(amount).then(tx => {
    //     console.log(tx)
    // });

    // await pIC.connect(deployer).redeemRewards().then(tx => {
    //     console.log(tx)
    // });

    //send daix to 2nd acc
    // await daix.connect(deployer).send("0xd97c2Ae7F17e46742F541b493671aa59AEAB70FE",sendAmount,"0x0000000000000000000000000000000000000000000000000000000000000000").then(tx => {
    //     console.log(tx)
    // });

    // console.log(await pIC.sentinelDaoToken())
    // const userBalance = ethers.utils.formatEther(await sent.balanceOf("0x6DA19238623C8a646679551f0863B6Bbc55E19D3"))
    // console.log(userBalance)

    // console.log(await pIC.amIPIC())
    // console.log(ethers.utils.formatEther(await sent.totalSupply()))

    // const ratio = ethers.utils.formatEther(await pIC.calculateSdtWorth())
    // console.log(ratio)

    // console.log(userBalance * ratio)

    // console.log(ethers.utils.formatEther(await pIC.stakeAndBalance()))
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error)
        process.exit(1)
    })
