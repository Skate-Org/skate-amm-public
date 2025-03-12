// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { OwnableUpgradeable } from
    "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { ISkateAppPeriphery } from "./interfaces/ISkateAppPeriphery.sol";
import { ISkateGateway } from "./interfaces/ISkateGateway.sol";

contract SkateAppPeriphery is OwnableUpgradeable, ISkateAppPeriphery {
    ISkateGateway _gateway;

    modifier onlyGateway() {
        require(msg.sender == address(_gateway), OnlyGatewayCanCall());
        _;
    }

    function __SkateAppPeriphery_init(address gateway_) public initializer {
        __Ownable_init(msg.sender);
        _gateway = ISkateGateway(gateway_);
    }

    function setGateway(address gateway_) external onlyGateway {
        _gateway = ISkateGateway(gateway_);
    }

    function gateway() external view override returns (address) {
        return address(_gateway);
    }
}
