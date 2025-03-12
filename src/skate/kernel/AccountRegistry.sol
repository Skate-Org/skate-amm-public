// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { OwnableUpgradeable } from
    "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from
    "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { ECDSA } from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import { IAccountRegistry } from "./interfaces/IAccountRegistry.sol";
import { AccountStorage } from "./AccountStorage.sol";
import { Utils } from "../common/utils/Utils.sol";

contract AccountRegistry is
    IAccountRegistry,
    AccountStorage,
    OwnableUpgradeable,
    UUPSUpgradeable,
    ReentrancyGuardUpgradeable,
    Utils
{
    constructor() {
        _disableInitializers();
    }

    function initialize(address relayer) public initializer {
        __ReentrancyGuard_init();
        __Ownable_init(msg.sender);
        _relayer = relayer;
        vm[++vmCount] = "EVM";
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override(UUPSUpgradeable)
        onlyOwner
    { }

    function setRelayer(address relayer) external override onlyOwner {
        _relayer = relayer;
    }

    function getBindEVMHash(
        bytes32 wallet1,
        uint256 vmType2,
        bytes32 wallet2
    )
        public
        pure
        returns (bytes32 bindHash)
    {
        bytes memory encodedData = abi.encode(0, wallet1, vmType2, wallet2);

        bindHash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n", itoa(bytes(encodedData).length), encodedData
            )
        );
    }

    function bindWallet(
        uint256 vmType1,
        bytes32 wallet1,
        uint256 vmType2,
        bytes32 wallet2,
        bytes memory signature1,
        bytes memory signature2
    )
        external
        onlyRelayer
    {
        require(vmType1 < vmType2, VmTypeNotOrdered());
        require(
            keccak256(abi.encodePacked(vm[vmType1])) != keccak256(abi.encodePacked("")),
            VmNotRegistered()
        );
        require(
            keccak256(abi.encodePacked(vm[vmType2])) != keccak256(abi.encodePacked("")),
            VmNotRegistered()
        );
        if (vmType1 == 1) {
            require(
                ECDSA.recover(getBindEVMHash(wallet1, vmType2, wallet2), signature1)
                    == address(uint160(uint256(wallet1))),
                InvalidBindSignature()
            );
        }
        //TODO else clause for onchain verification of nonEVM.

        require(
            _updateWalletBindings(vmType1, wallet1, vmType2, wallet2) == true,
            AddressAlreadyBinded()
        );
        emit WalletBinded(vmType1, wallet1, vmType2, wallet2, signature1, signature2);
    }

    function getWallets(uint256 vmType, bytes32 user) public view returns (bytes32[] memory) {
        bytes32 userHash = keccak256(abi.encodePacked(vmType, user));
        bytes32[] memory wallets = new bytes32[](vmCount);
        for (uint256 i = 0; i < accounts[references[userHash]].length; i++) {
            wallets[accounts[references[userHash]][i].vmType - 1] =
                accounts[references[userHash]][i].addr;
        }
        return wallets;
    }

    function getWalletBindingStatus(
        uint256 vmType,
        bytes32 user,
        uint256 vmType2,
        bytes32 user2
    )
        public
        view
        override
        returns (bool)
    {
        return references[keccak256(abi.encodePacked(vmType, user))]
            == references[keccak256(abi.encodePacked(vmType2, user2))];
    }

    function getAccountNumber(
        uint256 vmType,
        bytes32 user
    )
        external
        view
        returns (uint256 number)
    {
        return references[keccak256(abi.encodePacked(vmType, user))];
    }

    function getVmTypeByChainId(uint256 chainId) public view override returns (uint256 vmType) {
        return chainIdToVmType[chainId];
    }

    function registerVm(string memory name) external override onlyRelayer {
        vm[++vmCount] = name;
    }

    function setVmTypesToChainIds(
        uint256[] memory vmTypes,
        uint256[] memory chainIds
    )
        external
        onlyRelayer
    {
        require(vmTypes.length == chainIds.length, ArrayLengthMismatch());
        for (uint256 i = 0; i < vmTypes.length; i++) {
            string memory temp = vm[vmTypes[i]];
            require(
                keccak256(abi.encodePacked(temp)) != keccak256(abi.encodePacked("")),
                VmNotRegistered()
            );
            chainIdToVmType[chainIds[i]] = vmTypes[i];
        }
    }

    function getVm(uint256 index) external view returns (string memory) {
        return vm[index];
    }

    function getVmCount() public view returns (uint256) {
        return vmCount;
    }
}
