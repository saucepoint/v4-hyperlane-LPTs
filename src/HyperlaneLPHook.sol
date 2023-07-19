// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {BaseHook} from "v4-periphery/BaseHook.sol";

import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolId} from "@uniswap/v4-core/contracts/libraries/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";

import {IMailbox} from "hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";

contract HyperlaneLPHook is BaseHook {
    using PoolId for IPoolManager.PoolKey;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: false,
            afterModifyPosition: true,
            beforeSwap: false,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    function afterModifyPosition(
        address,
        IPoolManager.PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        BalanceDelta
    ) external override returns (bytes4) {
        {
            return BaseHook.afterModifyPosition.selector;
        }
    }
}
