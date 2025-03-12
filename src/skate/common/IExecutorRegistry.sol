// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/**
 * @notice interface for the contract {ExecutorRegistry}. It's a singleton contract managed by Skate team
 * that keeps track of all the whitelisted executors.
 * Owner of the {ExecutorRegistry} can whitelist or remove from whitelist the executors.
 */
interface IExecutorRegistry {
    error ZeroAddress();
    error ExecutorAlreadyAdded();
    error ExecutorNotAdded();

    event ExecutorAdded(address executor);
    event ExecutorRemoved(address executor);

    /**
     * @notice whitelists an executor.
     * @param executor address of executor to whitelist.
     * requirements:
     * - only owner can call this function.
     */
    function addExecutor(address executor) external;

    /**
     * @notice removes an executor from whitelist.
     * @param executor address to remove as executor.
     * requirements:
     * - only owner can call it.
     */
    function removeExecutor(address executor) external;

    /**
     * @notice returns if an executor is whitelisted or not.
     * @param executor address to check the whitelist status for.
     */
    function isExecutor(address executor) external view returns (bool);

    /**
     * @notice returns the list for all executors.
     */
    function executorsList() external view returns (address[] memory);
}
