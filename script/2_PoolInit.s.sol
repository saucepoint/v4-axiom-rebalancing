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

    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);
    address public constant AXIOM_V2_QUERY_GOERLI_ADDR = 0x8DdE5D4a8384F403F888E1419672D94C570440c9;
    bytes32 public constant DATA_QUERY_QUERY_SCHEMA = bytes32(0);
    bytes32 public constant COMPUTE_QUERY_QUERY_SCHEMA =
        0x1e9129a2abe9fd64aabd42b3c559b98af28dc6e7b26d6f4074238147485bbd70;
    address public constant manager = 0x862Fa52D0c8Bca8fBCB5213C9FEbC49c87A52912;
    address public constant swapRouter = 0x7B2B5A2c377B34079589DDbCeA20427cdb7C8219;

    // from 1_Tokens.s.sol/run-latest.json
    PoolModifyPositionTest router = PoolModifyPositionTest(0xeb4708989b42f0cd327A6Bd8f76a931429137fd7);
    MockERC20 token0 = MockERC20(0x1B4F103Ff3FdaE81E75Ec278256E5B4f4728b2B2);
    MockERC20 token1 = MockERC20(0x5Bf9FAbb0d56515658b7d5CC4B1F5c4EaED09e49);

    uint160 public constant MIN_PRICE_LIMIT = TickMath.MIN_SQRT_RATIO + 1;
    uint160 public constant MAX_PRICE_LIMIT = TickMath.MAX_SQRT_RATIO - 1;

    function setUp() public {}

    function run() public {
        // --- DEPLOY HOOK --- //
        // hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(Hooks.BEFORE_MODIFY_POSITION_FLAG);

        // Mine a salt that will produce a hook address with the correct flags
        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, 1000, type(Counter).creationCode, abi.encode(manager));

        // Deploy the hook using CREATE2
        vm.broadcast();
        Counter counter = new Counter{salt: salt}(IPoolManager(manager));
        require(address(counter) == hookAddress, "CounterScript: hook address mismatch");

        // init pool
        vm.startBroadcast();
        PoolKey memory key =
            PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(counter));
        IPoolManager(manager).initialize(key, SQRT_RATIO_1_1, ZERO_BYTES);
        vm.stopBroadcast();

        // create liquidity
        vm.broadcast();
        router.modifyPosition(key, IPoolManager.ModifyPositionParams(-60, 60, 10 ether), ZERO_BYTES);

        // swap
        vm.startBroadcast();
        token0.approve(address(swapRouter), 1000e18);
        token1.approve(address(swapRouter), 1000e18);
        vm.stopBroadcast();
        bool zeroForOne = true;
        int256 amount = 10e18;
        IPoolManager.SwapParams memory params = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: amount,
            sqrtPriceLimitX96: zeroForOne ? MIN_PRICE_LIMIT : MAX_PRICE_LIMIT // unlimited impact
        });

        PoolSwapTest.TestSettings memory testSettings =
            PoolSwapTest.TestSettings({withdrawTokens: true, settleUsingTransfer: true});

        vm.broadcast();
        PoolSwapTest(swapRouter).swap(key, params, testSettings);
    }
}
