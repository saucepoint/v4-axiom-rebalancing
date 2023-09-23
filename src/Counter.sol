// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseHook} from "v4-periphery/BaseHook.sol";

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {Pool} from "@uniswap/v4-core/contracts/libraries/Pool.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/contracts/types/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {IAxiomV1Query} from "./external/interfaces/IAxiomV1Query.sol";

struct ResponseStruct {
    bytes32 keccakBlockResponse;
    bytes32 keccakAccountResponse;
    bytes32 keccakStorageResponse;
    IAxiomV1Query.BlockResponse[] blockResponses;
    IAxiomV1Query.AccountResponse[] accountResponses;
    IAxiomV1Query.StorageResponse[] storageResponses;
}

contract Counter is BaseHook {
    using PoolIdLibrary for PoolKey;

    uint256 public afterModifyPositionCount;

    // TODO: immutable / set on deployment?
    IAxiomV1Query public constant axiomQuery = IAxiomV1Query(0x7DFbaa7a8E8f6e9b86C8EbDE4B7bd1E6bFf8Fae6);

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
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

    function beforeModifyPosition(
        address,
        PoolKey calldata key,
        IPoolManager.ModifyPositionParams calldata,
        bytes calldata hookData
    ) external override returns (bytes4) {
        return BaseHook.beforeModifyPosition.selector;
        ResponseStruct memory response = abi.decode(hookData, (ResponseStruct));
        bool valid = axiomQuery.areResponsesValid(
            response.keccakBlockResponse,
            response.keccakAccountResponse,
            response.keccakStorageResponse,
            response.blockResponses,
            response.accountResponses,
            response.storageResponses
        );
        if (!valid) revert("invalid axiom");

        IAxiomV1Query.StorageResponse memory storageData = response.storageResponses[0];

        // state data is coming from PoolManager
        require(storageData.addr == address(poolManager), "axiom: not poolmanager");

        // TODO: state data is more than 24 hours old
        require(storageData.blockNumber < block.number, "axiom: state too new");

        // TODO: confirm its slot0 holds tick data
        require(storageData.slot == 0, "axiom: not slot0");

        // get old tick and current tick
        // assuming we use `cast index bytes32 <poolId> 10`, we get a storage slot for Pool.State
        // luckily slot0 is the first 216 bits of Pool.State
        uint256 value = storageData.value;
        int24 oldTick;
        assembly {
            oldTick := shr(32, value) // clear out the bottom 32 bits, fee data
            // keep the bottom 24 bits
            oldTick := and(0xFFFFFF, oldTick)
        }
        (, int24 tick,,,,) = poolManager.getSlot0(key.toId());

        // TODO: old state meets market conditions
        require(oldTick < tick, "axiom: market conditions not met");

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
