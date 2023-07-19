// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IMessageRecipient} from "hyperlane-monorepo/solidity/contracts/interfaces/IMessageRecipient.sol";
import {IMailbox} from "hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";

contract LPBenefits is IMessageRecipient {
    /**
     * @notice Handle an interchain message
     * @param _origin Domain ID of the chain from which the message came
     * @param _sender Address of the message sender on the origin chain as bytes32
     * @param _body Raw bytes content of message body
     */
    function handle(uint32 _origin, bytes32 _sender, bytes calldata _body) external {
        require(_origin == 1, "Must be from mainnet");
    }
}
