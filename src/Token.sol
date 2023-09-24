// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";

contract YiToken is ERC20 {
    // YiToken is deployed as a test token and knows how to party.
    constructor(uint initialSupply) public ERC20("Yi", "YI") {
        _mint(initialSupply, 10 ** 8 * 10 ** 18);
    }

    function mint(address to, uint256 amount) public {
        uint256 balanceNext = balanceOf[to] + amount;
        require(balanceNext >= amount, "overflow balance");
        balanceOf[to] = balanceNext;
    }
}

contract TyllenToken is ERC20 {
    // TyllenToken is deployed as a test token and is super cool.
    constructor(uint initialSupply) public ERC20("Tyllen", "TYL") {
        _mint(initialSupply, 10 ** 8 * 10 ** 18);
    }

    function mint(address to, uint256 amount) public {
        uint256 balanceNext = balanceOf[to] + amount;
        require(balanceNext >= amount, "overflow balance");
        balanceOf[to] = balanceNext;
    }
}
