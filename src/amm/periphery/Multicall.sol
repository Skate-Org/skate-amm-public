// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Multicall is Ownable {
    mapping(address => bool) public isWhitelisted;
    address[] public whitelist;

    struct Call {
        address target;
        bytes callData;
    }

    modifier onlyWhitelisted() {
        require(isWhitelisted[msg.sender], "Multicall: caller is not whitelisted");
        _;
    }

    constructor() Ownable(msg.sender) { }

    function addToWhitelist(address target) external onlyOwner {
        if (!isWhitelisted[target]) {
            whitelist.push(target);
            isWhitelisted[target] = true;
        }
    }

    function removeFromWhitelist(address target) external onlyOwner {
        if (isWhitelisted[target]) {
            uint256 length = whitelist.length;
            for (uint256 i = 0; i < length; i++) {
                if (whitelist[i] == target) {
                    whitelist[i] = whitelist[length - 1];
                    whitelist.pop();
                    break;
                }
            }
            isWhitelisted[target] = false;
        }
    }

    function aggregate(Call[] memory calls) public onlyWhitelisted {
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory data) = calls[i].target.call(calls[i].callData);
            if (!success) {
                assembly {
                    let data_size := mload(data)
                    revert(add(data, 0x20), data_size)
                }
            }
        }
    }

    function allWhitelist() external view returns (address[] memory) {
        return whitelist;
    }
}
