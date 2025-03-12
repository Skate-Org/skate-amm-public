// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { OwnableUpgradeable } from
    "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IMessageBox } from "./interfaces/IMessageBox.sol";
import { ISkateApp } from "./interfaces/ISkateApp.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { IAccountRegistry } from "./interfaces/IAccountRegistry.sol";

abstract contract SkateApp is OwnableUpgradeable, ISkateApp {
    using Address for address;

    IMessageBox _messageBox;
    IAccountRegistry _accountRegistry;
    mapping(uint256 chainId => bytes32 peripheryContract) _chainIdToPeripheryContract;
    uint256[] _chainIds;

    modifier onlyContract() {
        require(msg.sender == address(this), OnlyContractCanCall());
        _;
    }

    function __SkateApp_init(address messageBox_, address accountRegistry_) public initializer {
        __Ownable_init(msg.sender);
        _messageBox = IMessageBox(messageBox_);
        _accountRegistry = IAccountRegistry(accountRegistry_);
    }

    function setChainToPeripheryContract(
        uint256 chainId,
        bytes32 peripheryContract
    )
        external
        virtual
        override
        onlyOwner
    {
        if (peripheryContract == bytes32(0)) {
            uint256 length = _chainIds.length;
            for (uint256 i = 0; i < length; i++) {
                if (_chainIds[i] == chainId) {
                    _chainIds[i] = _chainIds[length - 1];
                    _chainIds.pop();
                    break;
                }
            }
        } else if (_chainIdToPeripheryContract[chainId] == bytes32(0)) {
            _chainIds.push(chainId);
        }
        _chainIdToPeripheryContract[chainId] = peripheryContract;
        emit PeripheryContractSet(peripheryContract, chainId);
    }

    function processIntent(IMessageBox.Intent calldata intent) external virtual override {
        // pass into a super function
        bytes memory data = address(this).functionCall(intent.intentData.intentCalldata);

        IMessageBox.Task[] memory tasks = abi.decode(data, (IMessageBox.Task[]));
        _messageBox.submitTasks(tasks, intent);
    }

    function chainIdToPeripheryContract(uint256 chainId)
        public
        view
        override
        returns (bytes32 peripheryContract)
    {
        require(
            (peripheryContract = _chainIdToPeripheryContract[chainId]) != bytes32(0),
            ZeroPeripheryContractAddress()
        );
    }

    function messageBox() external view override returns (address) {
        return address(_messageBox);
    }

    function getChainIds() external view override returns (uint256[] memory chainIds) {
        return _chainIds;
    }

    function setMessageBox(address newMessageBox) external onlyOwner {
        _messageBox = IMessageBox(newMessageBox);
    }
}
