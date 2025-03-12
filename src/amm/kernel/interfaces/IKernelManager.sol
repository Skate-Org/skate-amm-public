// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { KernelEventEmitter } from "src/amm/kernel/KernelEventEmitter.sol";
import { IMessageBox } from "src/skate/kernel/interfaces/IMessageBox.sol";

interface IKernelManager {
    function poolIdCounter() external view returns (uint256);

    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    function pools(address token0, address token1, uint24 fee) external view returns (address);

    function getKernelPoolDescription(address pool) external view returns (string memory);
    function getPeripheryPoolDataByKernelPoolAndChainId(
        address kernelPool,
        uint256 peripheryChainId
    )
        external
        view
        returns (bytes32 pool, bytes32 token0, bytes32 token1);

    function poolExists(address pool) external view returns (bool);

    function eventEmitter() external view returns (KernelEventEmitter);

    function initKernelPool(
        string calldata description,
        uint24 fee,
        uint160 initialPrice,
        address kernelPool
    )
        external;

    function setFeeProtocol(address pool, uint8 feeProtocol0, uint8 feeProtocol1) external;

    function addPeripheryPool(
        address kernelPool,
        bytes32 pool,
        bytes32 token0,
        bytes32 token1,
        uint256 chainId
    )
        external;

    function mint(bytes calldata mintData) external returns (IMessageBox.Task[] memory tasks);

    function burn(bytes calldata burnData) external returns (IMessageBox.Task[] memory tasks);

    function swap(bytes calldata swapData) external returns (IMessageBox.Task[] memory tasks);

    function collectProtocol(
        address kernelPool,
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested,
        uint256 taskChainId
    )
        external
        returns (IMessageBox.Task[] memory tasks);

    function lensSwap(
        address pool,
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    )
        external
        returns (uint256 amountOut, uint160 sqrtPriceX96After);

    function lensMint(
        address pool,
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    )
        external
        returns (uint256 amount0, uint256 amount1);

    function lensBurn(
        address pool,
        address from,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    )
        external
        returns (uint256 amount0, uint256 amount1);
}
