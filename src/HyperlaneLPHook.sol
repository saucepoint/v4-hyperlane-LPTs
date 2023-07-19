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

    IMailbox public immutable mailbox;
    uint32 public immutable destination;

    constructor(IPoolManager _poolManager, IMailbox _mailbox, uint32 _destination) BaseHook(_poolManager) {
        mailbox = _mailbox;
        destination = _destination;
    }

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
        address sender,
        IPoolManager.PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        BalanceDelta
    ) external override returns (bytes4) {
        {
            bytes memory data = abi.encode(sender);
            mailbox.dispatch(destination, bytes32(uint256(uint160(sender))), data);
            return BaseHook.afterModifyPosition.selector;
        }
    }
}
