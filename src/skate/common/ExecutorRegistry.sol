// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { IExecutorRegistry } from "./IExecutorRegistry.sol";

contract ExecutorRegistry is IExecutorRegistry, Ownable {
    mapping(address => bool) private _isExecutor;
    address[] private _executorsList;

    constructor() Ownable(msg.sender) { }

    function addExecutor(address executor) external override onlyOwner {
        require(executor != address(0x0), ZeroAddress());
        require(!_isExecutor[executor], ExecutorAlreadyAdded());

        _isExecutor[executor] = true;
        _executorsList.push(executor);

        emit ExecutorAdded(executor);
    }

    function removeExecutor(address executor) external override onlyOwner {
        require(executor != address(0x0), ZeroAddress());
        require(_isExecutor[executor], ExecutorNotAdded());

        uint256 length = _executorsList.length;
        for (uint256 i = 0; i < length; i++) {
            if (_executorsList[i] == executor) {
                _executorsList[i] = _executorsList[length - 1];
                _executorsList.pop();
                delete _isExecutor[executor];
                emit ExecutorRemoved(executor);
                break;
            }
        }
    }

    function isExecutor(address executor) external view override returns (bool) {
        return _isExecutor[executor];
    }

    function executorsList() external view override returns (address[] memory) {
        return _executorsList;
    }
}
