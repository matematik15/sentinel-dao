// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CustomERC20 is ERC20, ERC20Burnable, Ownable {
    constructor(string memory underlyingName, string memory underlyingSymbol) 
        ERC20(string.concat("Sentinel Dao Token - ", underlyingName), string.concat("SENT-", underlyingSymbol)) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}