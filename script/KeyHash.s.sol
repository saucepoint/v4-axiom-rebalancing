// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {PoolModifyPositionTest} from "../test/utils/PoolModifyPositionTest.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {Counter} from "../src/Counter.sol";
import {HookMiner} from "../test/utils/HookMiner.sol";
import {PoolSwapTest} from "@uniswap/v4-core/contracts/test/PoolSwapTest.sol";

contract PoolInitScript is Script, Deployers {
    using CurrencyLibrary for Currency;
    using PoolIdLibrary for PoolId;
    using PoolIdLibrary for PoolKey;

    PoolModifyPositionTest router = PoolModifyPositionTest(0xb602Cc585b440e901C8A3A51cAb4b4f2a6047681);
    MockERC20 _tokenA = MockERC20(0x07bFDc27077b4C09a8C38B22Ab48e224fE973777);
    MockERC20 _tokenB = MockERC20(0x4876480ED2A2C1c73C190b7019fe66aBc0d41eB9);
    MockERC20 token0;
    MockERC20 token1;

    function setUp() public {}

    function run() public {
        if (address(_tokenA) < address(_tokenB)) {
            token0 = _tokenA;
            token1 = _tokenB;
        } else {
            token0 = _tokenB;
            token1 = _tokenA;
        }
        Counter counter = Counter(0x209fE93F355A7A6fA4D94b39c70cA7dB1707CFd5);

        PoolKey memory key =
            PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(address(counter)));

        // 0xb6996c0a8402379ee2de072e61b8c614327e50cbd1316bfa70fa2aefbf76ffe6
        console2.logBytes32(PoolId.unwrap(key.toId()));
    }
}
