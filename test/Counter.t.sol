// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {HookTest} from "./utils/HookTest.sol";
import {Counter} from "../src/Counter.sol";
import {HookMiner} from "./utils/HookMiner.sol";

contract CounterTest is HookTest, Deployers, GasSnapshot {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    Counter counter;
    PoolKey poolKey;
    PoolId poolId;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        // creates the pool manager, test tokens, and other utility routers
        HookTest.initHookTestEnv();

        // Deploy the hook to an address with the correct flags
        uint160 flags = uint160(Hooks.BEFORE_MODIFY_POSITION_FLAG | Hooks.AFTER_MODIFY_POSITION_FLAG);
        (address hookAddress, bytes32 salt) =
            HookMiner.find(address(this), flags, 0, type(Counter).creationCode, abi.encode(address(manager)));
        counter = new Counter{salt: salt}(IPoolManager(address(manager)));
        require(address(counter) == hookAddress, "CounterTest: hook address mismatch");

        // Create the pool
        poolKey = PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(counter));
        poolId = poolKey.toId();
        manager.initialize(poolKey, SQRT_RATIO_1_1, ZERO_BYTES);

        // Provide liquidity to the pool
        modifyPositionRouter.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams(-60, 60, 10 ether), abi.encode(address(this))
        );
        modifyPositionRouter.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams(-120, 120, 10 ether), abi.encode(address(this))
        );
        modifyPositionRouter.modifyPosition(
            poolKey,
            IPoolManager.ModifyPositionParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 10 ether),
            abi.encode(address(this))
        );

        // deal tokens to alice and bob
        token0.transfer(alice, 100 ether);
        token1.transfer(alice, 100 ether);
        token0.transfer(bob, 100 ether);
        token1.transfer(bob, 100 ether);

        vm.startPrank(alice);
        token0.approve(address(modifyPositionRouter), 100 ether);
        token1.approve(address(modifyPositionRouter), 100 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        token0.approve(address(modifyPositionRouter), 100 ether);
        token1.approve(address(modifyPositionRouter), 100 ether);
        vm.stopPrank();
    }

    function testCounterHooks() public {
        // positions were created in setup()
        assertEq(counter.afterModifyPositionCount(), 3);

        console2.logBytes32(PoolId.unwrap(poolId));
    }

    // --- Router Tests --- //
    // Confirm that Bob cannot modify Alice's position using empty bytes
    function testNotAllowed() public {
        vm.prank(alice);
        modifyPositionRouter.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams(-60, 60, 10 ether), abi.encode(alice)
        );

        vm.startPrank(bob);
        vm.expectRevert();
        modifyPositionRouter.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams(-60, 60, 10 ether), abi.encode(alice)
        );
    }
}
