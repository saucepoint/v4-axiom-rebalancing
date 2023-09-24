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

    MockERC20 _tokenA = MockERC20(0xd962b16F4ec712D705106674E944B04614F077be);
    MockERC20 _tokenB = MockERC20(0x5bA874E13D2Cf3161F89D1B1d1732D14226dBF16);
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
        Counter counter = Counter(0x20894bB9fA315D68E70339A6b6D91e096e67F81C);

        PoolKey memory key =
            PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(address(counter)));
        
        // 0x1002df3974d44860b5acf65363fc522cdd4f2a9a52ef9ec769e565ab47bb2490
        console2.logBytes32(PoolId.unwrap(key.toId()));
    }
}