//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";
import "@superfluid-finance/ethereum-contracts/contracts/utils/TOGA.sol";
import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/utils/introspection/IERC1820Registry.sol";
import "./CustomERC20.sol";

//This interface is needed since the function isn't included in the latest version of TOGA.sol
interface ITOGAv2_ {
    /**
    * @dev allows previous PICs to withdraw bonds which couldn't be sent back to them
    * @param token The token for which to withdraw funds in custody
    */
    function withdrawFundsInCustody(ISuperToken token) external;
}


contract PIC is IERC777Recipient {
    ISuperToken public immutable superToken;
    TOGA public immutable toga;
    ITOGAv2_ public immutable togaV2;
    CustomERC20 public immutable sentinelDaoToken;
    IERC1820Registry constant internal _ERC1820_REG = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    constructor(ISuperToken superToken_, address toga_) {
        superToken = superToken_;
        sentinelDaoToken = new CustomERC20(superToken.name(), superToken.symbol());
        toga = TOGA(toga_);
        togaV2 = ITOGAv2_(toga_);

        bytes32 erc777TokensRecipientHash = keccak256("ERC777TokensRecipient");
        _ERC1820_REG.setInterfaceImplementer(address(this), erc777TokensRecipientHash, address(this));
    }

    function amIPIC() public view returns (bool) {
        return toga.getCurrentPIC(superToken) == address(this);
    }

    function stakeAndBalance() public view returns (uint256) {
        uint256 _bond = 0;
        if (amIPIC()) {
            (, _bond, ) = toga.getCurrentPICInfo(superToken);
        }
        return superToken.balanceOf(address(this)) + _bond;
    }

    function calculateSdtWorth() public view returns (uint256 worth) {
        return ((stakeAndBalance() * 10 ** sentinelDaoToken.decimals()) /
            sentinelDaoToken.totalSupply());
    }

    function becomePIC(
        uint256 amount,
        bytes memory data
    ) external onlySentHolders {
        superToken.send(address(toga), amount, data);
    }

    function fundPIC(uint256 amount) external onlyWhenExitRateIsZero {
        //before the contract is funded, the SENT tokens would be worth nothing in relative terms, i.e. 0
        //in that case we mint the exact same amount as of the transfered
        uint256 _amountToMint = amount;
        if (sentinelDaoToken.totalSupply() > 0) {
            _amountToMint =
                (amount * 10 ** sentinelDaoToken.decimals()) /
                calculateSdtWorth();
        }
        sentinelDaoToken.mint(msg.sender, _amountToMint);
        superToken.transferFrom(msg.sender, address(this), amount);
    }

    function redeemFunds(uint256 amount) external onlyWhenExitRateIsZero {
        superToken.transfer(
            msg.sender,
            (amount * calculateSdtWorth()) / 10 ** sentinelDaoToken.decimals()
        );
        sentinelDaoToken.burn(msg.sender, amount);
    }

    function redeemPICStake() external onlySentHolders {
        toga.changeExitRate(
            superToken,
            toga.getMaxExitRateFor(superToken, _getBond())
        );
    }

    function redeemRewards() external {
        togaV2.withdrawFundsInCustody(
            superToken
        );
    }

    function simulateLiquidationsRewards(uint256 rewards) external {
        CustomERC20 underlyingToken = CustomERC20(
            superToken.getUnderlyingToken()
        );
        underlyingToken.mint(address(this), rewards);
        underlyingToken.approve(address(superToken), rewards);
        superToken.upgrade(rewards);
    }

    //internal functions
    function _getBond() internal view returns (uint256 bond) {
        (, uint256 _bond, ) = toga.getCurrentPICInfo(superToken);
        return _bond;
    }

    //modifiers

    //If an exit stream exists, funding the PIC or redeeming tokens isn't possible.
    //This would mess up the calculation of the (remaining) SENT tokens that will be redeemed in the future ones the stream finishes.
    modifier onlyWhenExitRateIsZero() {
        if (amIPIC()) {
            (, , int96 _exitRate) = toga.getCurrentPICInfo(superToken);
            require(_exitRate == 0, "Stake redemption ongoing");
        }
        _;
    }

    //only SENT holders with at least 10% total supply of SENT can call this
    modifier onlySentHolders() {
        require(
            sentinelDaoToken.balanceOf(msg.sender) >=
                sentinelDaoToken.totalSupply() / 10,
            "At least 10% of all SENTs needed"
        );
        _;
    }

    // ============ IERC777Recipient ============

    // interface through which ERC777 tokens are deposited to this contract
    function tokensReceived(
        address /*operator*/,
        address /*from*/,
        address /*to*/,
        uint256 amount,
        bytes calldata userData,
        bytes calldata /*operatorData*/
    ) override external {}
}