// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { IMessageBox } from "../../kernel/interfaces/IMessageBox.sol";

/**
 * @notice {SkateGateway} contract acts as entry point for the Skate apps for executing tasks on the peripherical chains.
 * This contract would call the Skate app's peripheral contract to perform execution
 */
interface ISkateGateway {
    struct TaskData {
        uint256 taskId;
        IMessageBox.Task task;
        bytes signature;
    }

    error ZeroAddress();
    error NotAnExecutor();
    error TaskAlreadyExecuted();
    error IncorrectChainId();
    error InvalidTaskSignature();

    event ExecutorRegistryAdded();
    event SignerSet(address signer);
    event TaskExecuted(uint256 taskId, IMessageBox.Task task);

    /**
     * @notice sets the executor registry contract's address.
     * @param executorRegistry_ address of executor registry contract.
     * requirements:
     * - only Skate app owner can call this function.
     */
    function setExecutorRegistry(address executorRegistry_) external;

    /**
     * @notice sets the signer address. Signer is the account set up on relayer who signs the tasks.
     * @param signer_ address of the signer
     * requirements:
     * - only manager can call it.
     */
    function setSigner(address signer_) external;

    /**
     * is called by executor to execute the tasks by passing in the task data.
     * @param taskData the data of the task to be executed.
     * @return success status of the underlying task execution.
     * @return returndata return data of the underlying task execution.
     * requirements:
     * - only a whitelisted executor can call it.
     */
    function executeTask(TaskData calldata taskData)
        external
        payable
        returns (bool success, bytes memory returndata);

    /**
     * @notice returns the address of {ExecutorRegistry} contract.
     * @param executorRegistry_ address of the executorRegistry.
     */
    function executorRegistry() external view returns (address executorRegistry_);

    /**
     * @notice returns the signer address.
     * @return signer_ address of the signer.
     */
    function signer() external view returns (address signer_);

    /**
     * @notice retruns hash of the task data passed to the function.
     * @param taskId id of the task.
     * @param appAddress the address of the periphery contract.
     * @param taskCalldata the calldata of the function call on the periphery contract.
     * @param user address of the user who initated the intent.
     * @param chainId id of the chain where periphery contract is deployed.
     * @return encodedData the hash of the task data passed to the function.
     */
    function getDataHash(
        uint256 taskId,
        address appAddress,
        bytes calldata taskCalldata,
        address user,
        uint256 chainId
    )
        external
        view
        returns (bytes memory encodedData);

    /**
     * @notice returns if a task with {taskId} has been executed or not.
     * @param taskId the id of the task to get the execution status for.
     * @return isExecuted boolean representing if the task has been executed.
     */
    function taskExecuted(uint256 taskId) external view returns (bool isExecuted);
}
