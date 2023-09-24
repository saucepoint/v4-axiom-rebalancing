// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import {Counter} from "../src/Counter.sol";
import {YiToken} from 

// import {UselessToken} from "../src/UselessToken.sol";

contract UniPoolScript is Script {
    address public constant AXIOM_V2_QUERY_GOERLI_ADDR =
        0x8DdE5D4a8384F403F888E1419672D94C570440c9;
    bytes32 public constant DATA_QUERY_QUERY_SCHEMA = bytes32(0);
    bytes32 public constant COMPUTE_QUERY_QUERY_SCHEMA =
        0x1e9129a2abe9fd64aabd42b3c559b98af28dc6e7b26d6f4074238147485bbd70;
    address public constant PoolManager =
        0x862Fa52D0c8Bca8fBCB5213C9FEbC49c87A52912;
    address public constant PoolSwapTest =
        0x7B2B5A2c377B34079589DDbCeA20427cdb7C8219;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_GOERLI");
        vm.startBroadcast();
        vm.warp(); // to-do?

        // Counter c = new UniPool(PoolManager, 5, COMPUTE_QUERY_QUERY_SCHEMA);

        poolKey = PoolKey(
            Currency.wrap(address(token0)),
            Currency.wrap(address(token1)),
            3000,
            60,
            IHooks(hooks)
        );
        poolId = PoolIdLibrary.toId(poolKey);
        bytes memory initData = abi.encode(
            uint16(144),
            uint64(block.timestamp)
        );
        manager.initialize(poolKey, SQRT_RATIO_1_1, initData);
    }

     function swap(PoolKey memory key, int256 amountSpecified, bool zeroForOne) internal {
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: zeroForOne ? MIN_PRICE_LIMIT : MAX_PRICE_LIMIT // unlimited impact
        });

        PoolSwapTest.TestSettings memory testSettings =
            PoolSwapTest.TestSettings({withdrawTokens: true, settleUsingTransfer: true});

        swapRouter.swap(key, params, testSettings);
    }

    // vm.stopBroadcast();
    // }
}