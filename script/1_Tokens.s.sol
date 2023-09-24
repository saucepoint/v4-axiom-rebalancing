// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {PoolModifyPositionTest} from "../test/utils/PoolModifyPositionTest.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";

contract TokensScript is Script {

    MockERC20 token0;
    MockERC20 token1;

    function setUp() public {}

    // forge script script/1_Tokens.s.sol --rpc-url https://rpc.ankr.com/eth_goerli	--private-key ...
    function run() public {
        vm.startBroadcast();
        // deploy router
        PoolModifyPositionTest router = new PoolModifyPositionTest(IPoolManager(address(0x862Fa52D0c8Bca8fBCB5213C9FEbC49c87A52912)));

        // deploy tokens
        MockERC20 tokenA = new MockERC20("Yi", "YI", 18);
        MockERC20 tokenB = new MockERC20("Tyllen", "TYL", 18);

        // mint tokens to sender
        tokenA.mint(msg.sender, 1000e18);
        tokenB.mint(msg.sender, 1000e18);

        tokenA.approve(address(router), 1000e18);
        tokenB.approve(address(router), 1000e18);
        vm.stopBroadcast();
    }
}