// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {BaseHook} from "v4-periphery/BaseHook.sol";

import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {PoolId} from "@uniswap/v4-core/contracts/libraries/PoolId.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";

import {IMailbox} from "hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";
import {LPT} from "./examples/LPBenefits.sol";

contract HyperlaneLPHook is BaseHook {
    using PoolId for IPoolManager.PoolKey;

    IMailbox public immutable mailbox;
    uint32 public immutable destination;
    bytes32 public immutable receiveAddr;

    constructor(IPoolManager _poolManager, IMailbox _mailbox, uint32 _destination, bytes32 _receiveAddr)
        BaseHook(_poolManager)
    {
        mailbox = _mailbox;
        destination = _destination;
        receiveAddr = _receiveAddr;
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
            bytes memory data = abi.encode((LPT({amount: 10 ether, holder: sender})));
            mailbox.dispatch(destination, receiveAddr, data);
            return BaseHook.afterModifyPosition.selector;
        }
    }
}
