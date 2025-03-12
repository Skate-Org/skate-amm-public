// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { IPeripheryManager } from "./interfaces/IPeripheryManager.sol";

contract PeripheryEventEmitter {
    IPeripheryManager manager;

    event Minted(
        address pool,
        address kernelPool,
        address user,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1
    );

    event MintSettled(
        address pool,
        address kernelPool,
        address user,
        uint256 amount0Settled,
        uint256 amount1Settled
    );

    event Burned(address peripheryPool, address kernelPool, address from, uint128 liquidity);

    event PoolCreated(address kernelPool, address pool, address token0, address token1, uint24 fee);

    // event CollectFee(uint256 actionId, address kernelPool, address pool, address user);

    event TransferredTo(
        address peripheryPool, address kernelPool, address user, uint256 amount0, uint256 amount1
    );

    event Swapped(
        address peripheryPool,
        address kernelPool,
        address user,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    );

    constructor() {
        manager = IPeripheryManager(msg.sender);
    }

    function mint(
        address peripheryPool,
        address kernelPool,
        address user,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1
    )
        external
    {
        _isValidCaller(peripheryPool);
        emit Minted(peripheryPool, kernelPool, user, tickLower, tickUpper, amount0, amount1);
    }

    function mintSettled(
        address peripheryPool,
        address kernelPool,
        address user,
        uint256 amount0Settled,
        uint256 amount1Settled
    )
        external
    {
        _isValidCaller(peripheryPool);
        emit MintSettled(peripheryPool, kernelPool, user, amount0Settled, amount1Settled);
    }

    function burned(
        address peripheryPool,
        address kernelPool,
        address user,
        uint128 liquidity
    )
        external
    {
        _isValidCaller(peripheryPool);
        emit Burned(peripheryPool, kernelPool, user, liquidity);
    }

    function poolCreated(
        address kernelPool,
        address pool,
        address token0,
        address token1,
        uint24 fee
    )
        external
    {
        require(msg.sender == address(manager));
        emit PoolCreated(kernelPool, pool, token0, token1, fee);
    }

    // function collectFee(
    //     address kernelPool,
    //     address token0,
    //     address token1,
    //     uint24 fee,
    //     address user
    // )
    //     external
    // {
    //            _isValidCaller(token0, token1, fee);
    //            emit CollectFee(actionId, kernelPool, msg.sender, user);
    // }

    function transferredTo(
        address peripheryPool,
        address kernelPool,
        address user,
        uint256 amount0,
        uint256 amount1
    )
        external
    {
        _isValidCaller(peripheryPool);
        emit TransferredTo(peripheryPool, kernelPool, user, amount0, amount1);
    }

    function swapped(
        address peripheryPool,
        address kernelPool,
        address user,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    )
        external
    {
        _isValidCaller(peripheryPool);
        emit Swapped(
            peripheryPool, kernelPool, user, zeroForOne, amountSpecified, sqrtPriceLimitX96
        );
    }

    function _isValidCaller(address peripheryPool) private view {
        require(manager.poolExists(peripheryPool));
    }
}
