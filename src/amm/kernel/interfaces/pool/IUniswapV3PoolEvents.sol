// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.26;

interface IUniswapV3PoolEvents {
    event Initialize(address kernelPool, uint160 sqrtPriceX96, int24 tick);

    event Mint(
        address kernelPool,
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Collect(
        address kernelPool,
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    event Burn(
        address kernelPool,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address kernelPool,
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    event IncreaseObservationCardinalityNext(
        address kernelPool,
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    event SetFeeProtocol(
        address kernelPool,
        uint8 feeProtocol0Old,
        uint8 feeProtocol1Old,
        uint8 feeProtocol0New,
        uint8 feeProtocol1New
    );

    event CollectProtocol(
        address kernelPool,
        address indexed sender,
        address indexed recipient,
        uint128 amount0,
        uint128 amount1
    );
}
