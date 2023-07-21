// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import {LPBenefits} from "../src/examples/LPBenefits.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";

/// @notice Forge script for deploying v4 & hooks to **anvil**
/// @dev This script only works on an anvil RPC because v4 exceeds bytecode limits
/// @dev and we also need vm.etch() to deploy the hook to the proper address
contract DeployBenefitsScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        MockERC20 rewardToken = new MockERC20("Reward Token", "RT", 18);
        LPBenefits lpBenefits = new LPBenefits(address(rewardToken));
        lpBenefits.setRewardsDuration(60 * 60 * 24 * 7); // 1 week
        rewardToken.mint(address(msg.sender), 100e18);
        rewardToken.transfer(address(lpBenefits), 100e18);
        lpBenefits.notifyRewardAmount(100e18);
        vm.stopBroadcast();
    }
}
