// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { ActionBox } from "src/skate/periphery/ActionBox.sol";
import { PeripheryEventEmitter } from "../PeripheryEventEmitter.sol";
import { ISkateAppPeriphery } from "src/skate/periphery/interfaces/ISkateAppPeriphery.sol";

interface IPeripheryManager is ISkateAppPeriphery {
    function eventEmitter() external view returns (PeripheryEventEmitter);

    function actionBox() external view returns (ActionBox);

    function kernelManager() external view returns (address);

    function pools(address token0, address token1, uint24 fee) external view returns (address);

    function isPoolFeeEnabled(uint24 fee) external view returns (bool);

    function poolExists(address pool) external view returns (bool);

    function initialize(address gateway_, address actionBox_, address kernelManager_) external;

    function setActionBox(address _actionBox) external;

    function setEventEmitter(address _eventEmitter) external;

    function createPool(
        address kernelPool,
        address token0,
        address token1,
        uint24 fee,
        string memory description
    )
        external
        returns (address);
}
