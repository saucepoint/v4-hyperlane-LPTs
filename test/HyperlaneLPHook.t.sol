// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolId} from "@uniswap/v4-core/contracts/libraries/PoolId.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/libraries/CurrencyLibrary.sol";

import {HookTest} from "./utils/HookTest.sol";
import {IMailbox} from "hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";
import {MockMailbox} from "hyperlane-monorepo/solidity/contracts/mock/MockMailbox.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";

import {HyperlaneLPHook} from "../src/HyperlaneLPHook.sol";
import {HyperlaneLPHookImplementation} from "./implementation/HyperlaneLPHookImplementation.sol";
import {LPBenefits} from "../src/examples/LPBenefits.sol";

contract HyperlaneLPHookTest is HookTest, Deployers, GasSnapshot {
    using PoolId for IPoolManager.PoolKey;
    using CurrencyLibrary for Currency;

    MockMailbox public mailbox = new MockMailbox(1);
    MockMailbox public remoteMailbox = new MockMailbox(2);

    MockERC20 public rewardToken = new MockERC20("Reward Token", "RT", 18);
    LPBenefits public lpBenefits = new LPBenefits(address(rewardToken));

    HyperlaneLPHook hook = HyperlaneLPHook(address(uint160(Hooks.AFTER_MODIFY_POSITION_FLAG)));
    IPoolManager.PoolKey poolKey;
    bytes32 poolId;

    function setUp() public {
        mailbox.addRemoteMailbox(2, remoteMailbox);

        // creates the pool manager, test tokens, and other utility routers
        HookTest.initHookTestEnv();

        // testing environment requires our contract to override `validateHookAddress`
        // well do that via the Implementation contract to avoid deploying the override with the production contract
        HyperlaneLPHookImplementation impl =
        new HyperlaneLPHookImplementation(manager, IMailbox(address(mailbox)), 2, bytes32(uint256(uint160(address(lpBenefits)))), hook);
        etchHook(address(impl), address(hook));

        // Create the pool
        poolKey =
            IPoolManager.PoolKey(Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(hook));
        poolId = PoolId.toId(poolKey);
        manager.initialize(poolKey, SQRT_RATIO_1_1);
    }

    function testProvision() public {
        // Provide liquidity to the pool
        modifyPositionRouter.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 10 ether)
        );

        // process the message
        remoteMailbox.processNextInboundMessage();
    }

    function testBurn() public {}
}
