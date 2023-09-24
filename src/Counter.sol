// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {console2} from "forge-std/console2.sol";
import {BaseHook} from "v4-periphery/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {Pool} from "@uniswap/v4-core/contracts/libraries/Pool.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {IAxiomV2client} from "./external/interfaces/IAxiomV2client.sol";

contract Counter is BaseHook, AxiomV2Client {
    using PoolIdLibrary for PoolKey;

    uint256 public afterModifyPositionCount;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return
            Hooks.Calls({
                beforeInitialize: false,
                afterInitialize: false,
                beforeModifyPosition: true,
                afterModifyPosition: true,
                beforeSwap: false,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false
            });
    }

    // axiom returns blockNumber, pool address, and price
    // strategy returns blockc

    function beforeModifyPosition(
        address,
        PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata hookData
    ) external override returns (bytes4) {
        (address sender, bytes memory data) = abi.decode(
            hookData,
            (address, bytes)
        );
        address owner = abi.decode(data, (address));
        require(sender == owner, "axiom: not owner");

        // _handleAxiom(key, hookData);
        return BaseHook.beforeModifyPosition.selector;
    }

    function afterModifyPosition(
        address,
        PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        BalanceDelta,
        bytes calldata
    ) external override returns (bytes4) {
        afterModifyPositionCount++;
        return BaseHook.afterModifyPosition.selector;
    }
}
