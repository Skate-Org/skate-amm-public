// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

import { SkateAppPeriphery } from "src/skate/periphery/SkateAppPeriphery.sol";
import { PeripheryPool } from "./PeripheryPool.sol";
import { PeripheryEventEmitter } from "./PeripheryEventEmitter.sol";
import { ActionBox } from "src/skate/periphery/ActionBox.sol";
import { IPeripheryManager } from "./interfaces/IPeripheryManager.sol";

contract PeripheryManager is IPeripheryManager, UUPSUpgradeable, SkateAppPeriphery {
    PeripheryEventEmitter public override eventEmitter;
    ActionBox public override actionBox;
    address public override kernelManager;

    // (token0 address => token1 address => fee => pool address)
    mapping(address => mapping(address => mapping(uint24 => address))) public override pools;
    mapping(uint24 => bool) public override isPoolFeeEnabled;
    mapping(address pool => bool exists) public override poolExists;

    constructor() {
        _disableInitializers();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override(UUPSUpgradeable)
        onlyOwner
    { }

    function initialize(
        address gateway_,
        address actionBox_,
        address kernelManager_
    )
        external
        override
        initializer
    {
        __SkateAppPeriphery_init(gateway_);
        // each periphery chain will have one event emitter contract
        eventEmitter = new PeripheryEventEmitter();
        actionBox = ActionBox(actionBox_);

        isPoolFeeEnabled[500] = true;
        isPoolFeeEnabled[3000] = true;
        isPoolFeeEnabled[10000] = true;
        kernelManager = kernelManager_;
    }

    function setActionBox(address _actionBox) external override onlyOwner {
        actionBox = ActionBox(_actionBox);
    }

    // An event emitter is deployed upon manager's deployment. The following
    // function is there just in case a new event emitter needs to be set.
    function setEventEmitter(address _eventEmitter) external override onlyOwner {
        eventEmitter = PeripheryEventEmitter(_eventEmitter);
    }

    // the pool must exist on kernel first.
    // after this pool creation, it must be registered on skate chain.
    function createPool(
        address kernelPool,
        address token0,
        address token1,
        uint24 fee,
        string memory description
    )
        external
        override
        onlyOwner
        returns (address)
    {
        require(isPoolFeeEnabled[fee], "fee is not enabled");
        require(pools[token0][token1][fee] == address(0x0), "pool already exists");
        address pool =
            address(new PeripheryPool(kernelManager, kernelPool, token0, token1, fee, description));
        pools[token0][token1][fee] = pool;
        pools[token1][token0][fee] = pool;
        poolExists[pool] = true;
        eventEmitter.poolCreated(kernelPool, pool, token0, token1, fee);
        return pool;
    }
}
