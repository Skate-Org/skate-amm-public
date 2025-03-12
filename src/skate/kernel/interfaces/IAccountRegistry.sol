// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/**
 * @notice interface for the contract {AccountRegistry}. It's a singleton contract managed by Skate team
 * that manages:
 * 1) registration of all VM types, chainIds to be supported by Skate.
 * 2) registration and binding of wallets across supported VMs.
 * This acts a wallet service for all Skate related services
 */
interface IAccountRegistry {
    event WalletBinded(
        uint256 chainType1,
        bytes32 wallet1,
        uint256 chainType2,
        bytes32 wallet2,
        bytes signature1,
        bytes signature2
    );

    error AddressAlreadyBinded();
    error VmTypeNotOrdered();
    error InvalidBindSignature();
    error ArrayLengthMismatch();
    error VmNotRegistered();
    error ChainIdAlreadyRegistered();
    error WalletNotBinded();

    /**
     * @notice returns hash required for EVM wallet binding
     * @param wallet1 the evm wallet address that is binded
     * @param chainType2 the chain type for wallet
     * @param wallet2 the non evm wallet address that is binded
     */
    function getBindEVMHash(
        bytes32 wallet1,
        uint256 chainType2,
        bytes32 wallet2
    )
        external
        returns (bytes32 bindHash);

    /**
     * @notice binds EVM wallet to nonEVM wallet.
     * @param chainType1 the chain type for wallet
     * @param wallet1 the evm wallet address that is binded
     * @param chainType2 the chain type for wallet
     * @param wallet2 the non evm wallet address that is binded
     * @param signature1 the signature of the first wallet
     * @param signature2 the signature of the second wallet
     */
    function bindWallet(
        uint256 chainType1,
        bytes32 wallet1,
        uint256 chainType2,
        bytes32 wallet2,
        bytes memory signature1,
        bytes memory signature2
    )
        external;
    /**
     * @notice gets all accounts binded across all VMs given chainType and the corresponding address for that chainType
     * @param vmType the chain type for user
     * @param user the user address
     * @return wallets returns a bytes32 array containing all addresses across all vm types.
     * The addresses are arranged in accordance to how it is in the ordered registered on AccountStorage
     * It also returns bytes32(0) if there is no such record.
     */
    function getWallets(
        uint256 vmType,
        bytes32 user
    )
        external
        view
        returns (bytes32[] memory wallets);

    /**
     * @notice retrieves account number tagged a spe
     * @param vmType the chain type for user
     * @param user the user address
     * @return number returns a uint256 number that represents a binded identity for all tagged wallets across different VMs.
     */
    function getAccountNumber(
        uint256 vmType,
        bytes32 user
    )
        external
        view
        returns (uint256 number);

    /**
     * @notice gets wallet binding status for the two provided wallets
     * @param vmType the chain type for wallet 1
     * @param user the user address for wallet 1
     * @param vmType the chain type for wallet 2
     * @param user2 the user address for wallet 2
     * @return status returns a boolean that represents whether the 2 provided wallets are binded
     */
    function getWalletBindingStatus(
        uint256 vmType,
        bytes32 user,
        uint256 vmType2,
        bytes32 user2
    )
        external
        view
        returns (bool status);

    /**
     * @notice gets name of vm at given index
     * @param index the index
     * @return vm returns the name of vm at given index
     */
    function getVm(uint256 index) external view returns (string memory vm);

    /**
     * @notice gets vmType for the given chainId
     * @param chainId the chain type for user
     * @return vmType returns the vmType for the given chainId
     */
    function getVmTypeByChainId(uint256 chainId) external view returns (uint256 vmType);

    /**
     * @notice registers vmType using name
     * @param name name of vmType to be registered.
     */
    function registerVm(string memory name) external;

    /**
     * @notice sets an array of provided chainIds to their corresponding vmType iteratively
     * @param vmTypes an array of vmTypes
     * @param chainIds an array of chainIds
     * NOTE: each element of vmTypes and chainIds should correspond to each other
     */
    function setVmTypesToChainIds(uint256[] memory vmTypes, uint256[] memory chainIds) external;

    /**
     * @notice gets number of registered Vms.
     * @return count returns number of registered Vms.
     */
    function getVmCount() external view returns (uint256 count);
}
