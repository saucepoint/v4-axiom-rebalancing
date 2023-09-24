// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {console2} from "forge-std/console2.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {IERC20Minimal} from "@uniswap/v4-core/contracts/interfaces/external/IERC20Minimal.sol";

import {ILockCallback} from "@uniswap/v4-core/contracts/interfaces/callback/ILockCallback.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";

// Forking v4-core's PoolModifyPositionTest to support arbitrary calldata
contract PoolModifyPositionTest is ILockCallback {
    using CurrencyLibrary for Currency;

    IPoolManager public immutable manager;

    constructor(IPoolManager _manager) {
        manager = _manager;
    }

    struct CallbackData {
        address sender;
        PoolKey key;
        IPoolManager.ModifyPositionParams params;
        bytes hookData;
    }

    function expand(uint64, address, bytes32, bytes32, bytes32[] calldata axiomResults, bytes calldata) external {
        // TODO: verify the additional axiom arguments

        PoolKey memory key = PoolKey(
            Currency.wrap(address(uint160(uint256(axiomResults[0])))),
            Currency.wrap(address(uint160(uint256(axiomResults[1])))),
            uint24(uint256(axiomResults[2])),
            int24(int256(uint256(axiomResults[3]))),
            IHooks(address(uint160(uint256(axiomResults[4]))))
        );
        uint256 slot0Old = uint256(axiomResults[5]);
        uint256 slot0New = uint256(axiomResults[6]);

        int24 tickOld;
        int24 tickNew;
        assembly {
            tickOld := shr(32, slot0Old)
            tickOld := and(tickOld, 0xFFFFFF)
            tickNew := shr(32, slot0New)
            tickNew := and(tickNew, 0xFFFFFF)
        }

        // TODO: actual tick comparisons
        if (tickOld < tickNew) {
            IPoolManager.ModifyPositionParams memory params = IPoolManager.ModifyPositionParams(-600_000, 600_000, 0);
            modifyPosition(key, params, abi.encode(msg.sender));
        }
    }

    function modifyPosition(PoolKey memory key, IPoolManager.ModifyPositionParams memory params, bytes memory hookData)
        public
        payable
        returns (BalanceDelta delta)
    {
        delta = abi.decode(manager.lock(abi.encode(CallbackData(msg.sender, key, params, hookData))), (BalanceDelta));

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            CurrencyLibrary.NATIVE.transfer(msg.sender, ethBalance);
        }
    }

    function lockAcquired(bytes calldata rawData) external returns (bytes memory) {
        require(msg.sender == address(manager));

        CallbackData memory data = abi.decode(rawData, (CallbackData));

        bytes memory hookData = abi.encode(data.sender, data.hookData);
        BalanceDelta delta = manager.modifyPosition(data.key, data.params, hookData);

        if (delta.amount0() > 0) {
            if (data.key.currency0.isNative()) {
                manager.settle{value: uint128(delta.amount0())}(data.key.currency0);
            } else {
                IERC20Minimal(Currency.unwrap(data.key.currency0)).transferFrom(
                    data.sender, address(manager), uint128(delta.amount0())
                );
                manager.settle(data.key.currency0);
            }
        }
        if (delta.amount1() > 0) {
            if (data.key.currency1.isNative()) {
                manager.settle{value: uint128(delta.amount1())}(data.key.currency1);
            } else {
                IERC20Minimal(Currency.unwrap(data.key.currency1)).transferFrom(
                    data.sender, address(manager), uint128(delta.amount1())
                );
                manager.settle(data.key.currency1);
            }
        }

        if (delta.amount0() < 0) {
            manager.take(data.key.currency0, data.sender, uint128(-delta.amount0()));
        }
        if (delta.amount1() < 0) {
            manager.take(data.key.currency1, data.sender, uint128(-delta.amount1()));
        }

        return abi.encode(delta);
    }
}
