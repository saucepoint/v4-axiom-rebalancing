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

contract Counter is BaseHook {
    using PoolIdLibrary for PoolKey;

    address public constant AXIOM_V2_QUERY = 0x8DdE5D4a8384F403F888E1419672D94C570440c9;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: true,
            afterModifyPosition: false,
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
        PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata hookData
    ) external pure override returns (bytes4) {
        (address sender, bytes memory data) = abi.decode(hookData, (address, bytes));
        address owner = abi.decode(data, (address));
        require(sender == owner || sender == AXIOM_V2_QUERY || owner == AXIOM_V2_QUERY, "axiom: not owner");
        return BaseHook.beforeModifyPosition.selector;
    }
}
