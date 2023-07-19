// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IMessageRecipient} from "hyperlane-monorepo/solidity/contracts/interfaces/IMessageRecipient.sol";
import {IMailbox} from "hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";
import {Emissions} from "./Emissions.sol";

struct LPT {
    uint256 amount;
    address holder;
}

contract LPBenefits is IMessageRecipient, Emissions {
    constructor(address _rewardToken) Emissions(_rewardToken) {}

    event Handler(uint256 amount, address holder);

    /**
     * @notice Handle an interchain message
     * @param _origin Domain ID of the chain from which the message came
     * @param _body Raw bytes content of message body
     */
    function handle(uint32 _origin, bytes32, bytes calldata _body) external {
        require(_origin == 1, "Must be from mainnet");
        // TODO: require the call originates from the hook address
        LPT memory lpt = abi.decode(_body, (LPT));
        stake(lpt.amount, lpt.holder);
        emit Handler(lpt.amount, lpt.holder);
    }
}
