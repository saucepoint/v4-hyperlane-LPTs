// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/contracts/libraries/TickMath.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolModifyPositionTest} from "@uniswap/v4-core/contracts/test/PoolModifyPositionTest.sol";
import {PoolSwapTest} from "@uniswap/v4-core/contracts/test/PoolSwapTest.sol";
import {PoolDonateTest} from "@uniswap/v4-core/contracts/test/PoolDonateTest.sol";
import {Deployers} from "@uniswap/v4-core/test/foundry-tests/utils/Deployers.sol";
import {CurrencyLibrary, Currency} from "@uniswap/v4-core/contracts/libraries/CurrencyLibrary.sol";

import {HyperlaneLPHook} from "../src/HyperlaneLPHook.sol";
import {HyperlaneLPHookImplementation} from "../test/implementation/HyperlaneLPHookImplementation.sol";
import {IMailbox} from "hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";
import {HookTest} from "../test/utils/HookTest.sol";

/// @notice Forge script for deploying v4 & hooks to **anvil**
/// @dev This script only works on an anvil RPC because v4 exceeds bytecode limits
/// @dev and we also need vm.etch() to deploy the hook to the proper address
contract HyperlaneLPHookScript is Script, HookTest, Deployers {
    using CurrencyLibrary for Currency;

    address public MAILBOX = address(0x0);
    address public LP_BENEFITS = address(0x0);

    function setUp() public {}

    function run() public {
        initHookTestEnv();

        // uniswap hook addresses must have specific flags encoded in the address
        // (attach 0x1 to avoid collisions with other hooks)
        uint160 targetFlags = uint160(Hooks.AFTER_MODIFY_POSITION_FLAG | 0x1);

        // TODO: eventually use bytecode to deploy the hook with create2 to mine proper addresses
        // bytes memory hookBytecode = abi.encodePacked(type(Counter).creationCode, abi.encode(address(manager)));

        // TODO: eventually we'll want to use `uint160 salt` in the return create2 deploy the hook
        // (address hook,) = mineSalt(targetFlags, hookBytecode);
        // require(uint160(hook) & targetFlags == targetFlags, "CounterScript: could not find hook address");

        vm.broadcast();
        // until i figure out create2 deploys on an anvil RPC, we'll use the etch cheatcode
        HyperlaneLPHookImplementation impl =
        new HyperlaneLPHookImplementation(manager, IMailbox(address(MAILBOX)), 2061, bytes32(uint256(uint160(LP_BENEFITS))), HyperlaneLPHook(address(targetFlags)));
        etchHook(address(impl), address(targetFlags));

        // Create the pool
        vm.startBroadcast();
        IPoolManager.PoolKey memory poolKey = IPoolManager.PoolKey(
            Currency.wrap(address(token0)), Currency.wrap(address(token1)), 3000, 60, IHooks(address(targetFlags))
        );
        manager.initialize(poolKey, SQRT_RATIO_1_1);

        // Provide liquidity to the pool
        modifyPositionRouter.modifyPosition(
            poolKey, IPoolManager.ModifyPositionParams(TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 10 ether)
        );
        vm.stopBroadcast();
    }

    function mineSalt(uint160 targetFlags, bytes memory creationCode)
        internal
        view
        returns (address hook, uint256 salt)
    {
        for (salt; salt < 100; salt++) {
            hook = _getAddress(salt, creationCode);
            if (uint160(hook) & targetFlags == targetFlags) {
                break;
            }
        }
    }

    function _getAddress(uint256 salt, bytes memory creationCode) internal view returns (address) {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(creationCode)))))
        );
    }
}
