// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { IPeripheryManager } from "./IPeripheryManager.sol";

interface IPeripheryPool {
    function kernelPool() external view returns (address);

    function kernelManager() external view returns (address);

    function manager() external view returns (IPeripheryManager);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function fee() external view returns (uint24);

    function usersData(address user) external view returns (uint256, uint256, uint256);

    function description() external view returns (string memory);

    function stagedToken0Amount() external view returns (uint256);

    function stagedToken1Amount() external view returns (uint256);

    function balancesAvailable() external view returns (uint256 token0, uint256 token1);

    function mint(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1,
        bytes calldata extraData
    )
        external;

    function settleMint(
        address user,
        uint256 amount0ToSettle,
        uint256 amount1ToSettle,
        uint256 amount0ToTransfer,
        uint256 amount1ToTransfer
    )
        external;

    function removeStagedAssets() external;

    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidityAmount,
        bytes calldata extraData
    )
        external;

    function settleBurn(address user, uint256 amount0, uint256 amount1) external;

    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata extraData
    )
        external; // must contain destChainId and vmType as uint256s

    function settleSwap(
        address user,
        uint256 amount0ToTransfer,
        uint256 amount1ToTransfer,
        uint256 amount0ToSettle,
        uint256 amount1ToSettle
    )
        external;
}
