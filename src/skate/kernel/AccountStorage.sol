// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

/**
 * @notice abstract contract for the contract {AccountRegistry}. Contains all storage variables and helper functions for {AccountRegistry}.
 */
abstract contract AccountStorage {
    //hash => address1 => address2
    //1 2 =>
    struct WalletInfo {
        uint256 vmType;
        bytes32 addr;
    }

    address _relayer;
    mapping(uint256 => string) vm;
    uint256 vmCount;
    mapping(bytes32 => mapping(bytes32 => bytes32)) vmDirectory;
    mapping(uint256 => uint256) chainIdToVmType;
    uint256 accountNumber;
    //each user has a refNumber, this refNumber is what binds diff addr.
    mapping(bytes32 => uint256) references;
    mapping(uint256 => WalletInfo[]) accounts;

    modifier onlyRelayer() {
        require(msg.sender == _relayer);
        _;
    }

    function _updateWalletBindings(
        uint256 vmType1,
        bytes32 wallet1,
        uint256 vmType2,
        bytes32 wallet2
    )
        internal
        returns (bool)
    {
        bytes32 wallet1Hash = keccak256(abi.encodePacked(vmType1, wallet1));
        bytes32 wallet2Hash = keccak256(abi.encodePacked(vmType2, wallet2));
        //both are not binded
        if (references[wallet1Hash] != 0 && references[wallet2Hash] != 0) return false;
        if (references[wallet1Hash] == 0 && references[wallet2Hash] == 0) {
            references[wallet1Hash] = ++accountNumber;
            references[wallet2Hash] = accountNumber;
            WalletInfo memory wallet1Info = WalletInfo(vmType1, wallet1);
            WalletInfo memory wallet2Info = WalletInfo(vmType2, wallet2);
            accounts[accountNumber].push(wallet1Info);
            accounts[accountNumber].push(wallet2Info);
            return true;
        }
        //wallet 1 is binded
        else if (references[wallet1Hash] != 0 && references[wallet2Hash] == 0) {
            references[wallet2Hash] = references[wallet1Hash];
            WalletInfo memory wallet2Info = WalletInfo(vmType2, wallet2);
            accounts[references[wallet1Hash]].push(wallet2Info);
            return true;
        }
        //wallet 2 is binded
        else if (references[wallet1Hash] == 0 && references[wallet2Hash] != 0) {
            references[wallet1Hash] = references[wallet2Hash];
            WalletInfo memory wallet1Info = WalletInfo(vmType1, wallet1);
            accounts[references[wallet2Hash]].push(wallet1Info);
            return true;
        }

        return false;
    }

    function setRelayer(address relayer) external virtual;
}
