// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/**
 * @notice {ISkateAppPeriphery} provides basic interface for a periphery contract of a skateApp.
 */
interface ISkateAppPeriphery {
    error OnlyGatewayCanCall();

    /**
     * @notice returns the address of skate gateway contract on the chain.
     */
    function gateway() external view returns (address);
}
