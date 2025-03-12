// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { IUniswapV3PoolEvents } from "./interfaces/pool/IUniswapV3PoolEvents.sol";
import { IKernelManager } from "./interfaces/IKernelManager.sol";

contract KernelEventEmitter is IUniswapV3PoolEvents {
    IKernelManager manager;

    event PoolCreated(address pool, string description, address token0, address token1, uint24 fee);
    event PeripheryPoolAdded(
        address kernelPoolAddress,
        uint256 peripheryChainId,
        bytes32 peripheryPool,
        bytes32 token0,
        bytes32 token1
    );

    modifier onlyKernelManager() {
        require(
            msg.sender == address(manager),
            "KernelEventEmitter::onlyKernelManager: only manager can call"
        );
        _;
    }

    modifier onlyKernelPool() {
        require(
            manager.poolExists(msg.sender),
            "KernelEventEmitter::onlyKernelPool: only kernel pool can call"
        );
        _;
    }

    constructor() {
        manager = IKernelManager(msg.sender);
    }

    function poolCreated(
        address kernelPool,
        string memory description,
        address token0,
        address token1,
        uint24 fee
    )
        external
        onlyKernelManager
    {
        emit PoolCreated(kernelPool, description, token0, token1, fee);
    }

    function peripheryPoolAdded(
        address poolAddress,
        uint256 peripheryChainId,
        bytes32 peripheryPool,
        bytes32 peripheryToken0,
        bytes32 peripheryToken1
    )
        external
        onlyKernelManager
    {
        emit PeripheryPoolAdded(
            poolAddress, peripheryChainId, peripheryPool, peripheryToken0, peripheryToken1
        );
    }

    function initialize(uint160 sqrtPriceX96, int24 tick) external onlyKernelPool {
        emit Initialize(msg.sender, sqrtPriceX96, tick);
    }

    function mint(
        address sender,
        address owner,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    )
        external
        onlyKernelPool
    {
        emit Mint(msg.sender, sender, owner, tickLower, tickUpper, amount, amount0, amount1);
    }

    function collect(
        address owner,
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0,
        uint128 amount1
    )
        external
        onlyKernelPool
    {
        emit Collect(msg.sender, owner, recipient, tickLower, tickUpper, amount0, amount1);
    }

    function burn(
        address owner,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    )
        external
        onlyKernelPool
    {
        emit Burn(msg.sender, owner, tickLower, tickUpper, amount, amount0, amount1);
    }

    function swap(
        address sender,
        address recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    )
        external
        onlyKernelPool
    {
        emit Swap(msg.sender, sender, recipient, amount0, amount1, sqrtPriceX96, liquidity, tick);
    }

    function increaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    )
        external
        onlyKernelPool
    {
        emit IncreaseObservationCardinalityNext(
            msg.sender, observationCardinalityNextOld, observationCardinalityNextNew
        );
    }

    function setFeeProtocol(
        uint8 feeProtocol0Old,
        uint8 feeProtocol1Old,
        uint8 feeProtocol0New,
        uint8 feeProtocol1New
    )
        external
        onlyKernelPool
    {
        emit SetFeeProtocol(
            msg.sender, feeProtocol0Old, feeProtocol1Old, feeProtocol0New, feeProtocol1New
        );
    }

    function collectProtocol(
        address sender,
        address recipient,
        uint128 amount0,
        uint128 amount1
    )
        external
        onlyKernelPool
    {
        emit CollectProtocol(msg.sender, sender, recipient, amount0, amount1);
    }
}
