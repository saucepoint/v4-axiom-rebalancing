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
    address public constant swapRouter = 0x7B2B5A2c377B34079589DDbCeA20427cdb7C8219;

    // from 1_Tokens.s.sol/run-latest.json
    IPoolManager manager = IPoolManager(0x862Fa52D0c8Bca8fBCB5213C9FEbC49c87A52912);
    PoolModifyPositionTest router = PoolModifyPositionTest(0xE5dF461803a59292c6c03978c17857479c40bc46);
    MockERC20 _tokenA = MockERC20(0xd962b16F4ec712D705106674E944B04614F077be);
    MockERC20 _tokenB = MockERC20(0x5bA874E13D2Cf3161F89D1B1d1732D14226dBF16);
    MockERC20 token0;
    MockERC20 token1;

    uint160 public constant MIN_PRICE_LIMIT = TickMath.MIN_SQRT_RATIO + 1;
    uint160 public constant MAX_PRICE_LIMIT = TickMath.MAX_SQRT_RATIO - 1;

    function setUp() public {}

    function run() public {
        if (address(_tokenA) < address(_tokenB)) {
            token0 = _tokenA;
            token1 = _tokenB;
        } else {
            token0 = _tokenB;
            token1 = _tokenA;
        }
        // --- DEPLOY HOOK --- //
        // hook contracts must have specific flags encoded in the address
        uint160 flags = uint160(Hooks.BEFORE_MODIFY_POSITION_FLAG);

        // Mine a salt that will produce a hook address with the correct flags
        (address hookAddress, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER, flags, 3000, type(Counter).creationCode, abi.encode(address(manager)));

        // Deploy the hook using CREATE2
        vm.broadcast();
        Counter counter = new Counter{salt: salt}(manager);
        require(address(counter) == hookAddress, "CounterScript: hook address mismatch");

        // init pool
        PoolKey memory key =
            PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(counter));
        vm.broadcast();
        manager.initialize(key, SQRT_RATIO_1_1, ZERO_BYTES);

        // create liquidity
        vm.broadcast();
        router.modifyPosition(key, IPoolManager.ModifyPositionParams(-6000, 6000, 1000 ether), abi.encode(msg.sender));
    }
}
