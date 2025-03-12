// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { IMessageBox } from "./IMessageBox.sol";

/**
 * @notice abstract contract to be inherited by all the Skate apps.
 * It provides the base functionality for the Skate app that allows setting Skate app's periphery
 * contract's against the chainId.
 * Also provides the basic implementation for executing intents.
 */
interface ISkateApp {
    error IntentProcessingReverted();
    error ZeroPeripheryContractAddress();
    error ZeroChainId();
    error OnlyContractCanCall();

    event PeripheryContractSet(bytes32 contractAddress, uint256 chainId);

    /**
     * @notice returns the address of Skate app's periphery contract against the provided {chainId}.
     * @param chainId the chain id to fetch the periphery contract against.
     * @return peripheryContract the address of the periphery contract.
     */
    function chainIdToPeripheryContract(uint256 chainId)
        external
        view
        returns (bytes32 peripheryContract);

    /**
     * @notice returns the list of chainIds that SkateApp has periphery contracts registered on.
     */
    function getChainIds() external view returns (uint256[] memory chainIds);

    /**
     * @notice returns the address of messsage box contract.
     */
    function messageBox() external view returns (address);

    /**
     * @notice allows processing of intents. An intent is processed by emitting event on the {MessageBox} contract/
     * @param intent the user signed intent to processed.
     */
    function processIntent(IMessageBox.Intent calldata intent) external;

    /**
     * @notice allows setting of periphery contracts addresses against the chainId for the Skate app.
     * @param chainId the chainId to set the periphery contract address for.
     * @param peripheryContract address of periphery contract address.
     */
    function setChainToPeripheryContract(uint256 chainId, bytes32 peripheryContract) external;
}
