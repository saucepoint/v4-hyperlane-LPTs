// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {HyperlaneLPHook} from "../../src/HyperlaneLPHook.sol";

import {BaseHook} from "v4-periphery/BaseHook.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";

import {IMailbox} from "hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";

contract HyperlaneLPHookImplementation is HyperlaneLPHook {
    constructor(
        IPoolManager poolManager,
        IMailbox mailbox,
        uint32 destination,
        bytes32 receiveAddr,
        HyperlaneLPHook addressToEtch
    ) HyperlaneLPHook(poolManager, mailbox, destination, receiveAddr) {
        Hooks.validateHookAddress(addressToEtch, getHooksCalls());
    }

    // make this a no-op in testing
    function validateHookAddress(BaseHook _this) internal pure override {}
}
