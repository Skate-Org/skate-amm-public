// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import { IPeripheryPool } from "./interfaces/IPeripheryPool.sol";

import { IPeripheryManager } from "./interfaces/IPeripheryManager.sol";
import { ActionBox } from "src/skate/periphery/ActionBox.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";

// TODO: make ownable
// utilizing global variables
contract PeripheryPool is IPeripheryPool {
    // skate chain variables
    address public override kernelPool;
    address public override kernelManager;

    // periphery chain variables
    IPeripheryManager public override manager;
    address public override token0;
    address public override token1;
    uint24 public override fee;

    string public override description;

    uint256 public override stagedToken0Amount;
    uint256 public override stagedToken1Amount;

    struct UserData {
        uint256 amount0;
        uint256 amount1;
        uint256 withdrawAfter;
    }

    mapping(address => UserData) public override usersData;

    uint8 public constant NORMALIZED_DECIMAL = 18;

    modifier onlyGateway() {
        require(msg.sender == manager.gateway(), "only gateway can call");
        _;
    }

    constructor(
        address _kernelManager,
        address _kernelPool,
        address _token0,
        address _token1,
        uint24 _fee,
        string memory _description
    ) {
        kernelManager = _kernelManager;
        kernelPool = _kernelPool;
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        manager = IPeripheryManager(msg.sender);
        description = _description;
    }

    function balancesAvailable()
        public
        view
        override
        returns (uint256 amount0Available, uint256 amount1Available)
    {
        amount0Available = IERC20(token0).balanceOf(address(this)) - stagedToken0Amount;
        amount1Available = IERC20(token1).balanceOf(address(this)) - stagedToken1Amount;
    }

    function mint(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1,
        bytes calldata extraData // must contain amount0Min, amount1Min
    )
        external
        override
    {
        require(amount0 != 0 || amount1 != 0, "invalid token0/token1 amount");
        stagedToken0Amount += amount0;
        stagedToken1Amount += amount1;

        UserData storage data = usersData[msg.sender];
        data.amount0 += amount0;
        data.amount1 += amount1;

        // user can withdraw after two hours
        data.withdrawAfter = block.timestamp + 10 minutes;

        uint256 amount0Normalized = _normalizeTokenAmount(uint56(amount0), token0);
        uint256 amount1Normalized = _normalizeTokenAmount(uint56(amount1), token1);

        ActionBox.Action memory action;
        action.actionId = manager.actionBox().getActionId(msg.sender);
        action.kernelAppAddress = kernelManager;
        action.kernelAppCalldata = abi.encodeWithSignature(
            "mint(bytes)",
            abi.encode(
                action.actionId,
                block.chainid,
                1, // vmType
                _fromAddressToBytes32(msg.sender),
                kernelPool,
                tickLower,
                tickUpper,
                amount0Normalized,
                amount1Normalized,
                extraData
            )
        );

        action.tokens = new address[](2);
        action.amounts = new uint256[](2);
        action.tokens[0] = token0;
        action.amounts[0] = amount0Normalized;
        action.tokens[1] = token1;
        action.amounts[1] = amount1Normalized;
        action.user = _fromAddressToBytes32(msg.sender);
        manager.actionBox().createAction(action);
        if (amount0 != 0) IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        if (amount1 != 0) IERC20(token1).transferFrom(msg.sender, address(this), amount1);

        manager.eventEmitter().mint(
            address(this), kernelPool, msg.sender, tickLower, tickUpper, amount0, amount1
        );
    }

    // called by executor to notify the mint is successful and certain amounts of assets
    // has been credited to user's book on kernel contract.
    function settleMint(
        address user,
        uint256 amount0ToSettle,
        uint256 amount1ToSettle,
        uint256 amount0ToTransfer,
        uint256 amount1ToTransfer
    )
        external
        override
        onlyGateway
    {
        _settle(
            user,
            _denormalizeTokenAmount(amount0ToSettle, token0),
            _denormalizeTokenAmount(amount1ToSettle, token1)
        );
        _transferTo(user, amount0ToTransfer, amount1ToTransfer);
    }

    function removeStagedAssets() external override {
        UserData memory userData = usersData[msg.sender];
        require(block.timestamp > userData.withdrawAfter, "withdraw window has not arrived yet");
        uint256 amount0 = userData.amount0;
        uint256 amount1 = userData.amount1;
        _settle(msg.sender, amount0, amount1);
        IERC20(token0).transfer(msg.sender, amount0);
        IERC20(token1).transfer(msg.sender, amount1);
        // no action needed
    }

    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidityAmount,
        bytes calldata extraData // must contain amount0Min, amount01in
    )
        external
        override
    {
        ActionBox.Action memory action;
        action.actionId = manager.actionBox().getActionId(msg.sender);
        action.kernelAppAddress = kernelManager;
        action.kernelAppCalldata = abi.encodeWithSignature(
            "burn(bytes)",
            abi.encode(
                action.actionId,
                block.chainid,
                1, // vmType
                _fromAddressToBytes32(msg.sender),
                kernelPool,
                tickLower,
                tickUpper,
                liquidityAmount,
                extraData
            )
        );
        action.user = _fromAddressToBytes32(msg.sender);
        manager.actionBox().createAction(action);

        manager.eventEmitter().burned(address(this), kernelPool, msg.sender, liquidityAmount);
    }

    function settleBurn(
        address user,
        uint256 amount0,
        uint256 amount1
    )
        external
        override
        onlyGateway
    {
        _transferTo(user, amount0, amount1);
    }

    // called by user to swap token0 -> token1 or vice-versa.
    // the approval must be performed to pool contract for the token being swapped from.
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata extraData // must contain minimumAmountOut, destChainId, vmType as uint256s
    )
        external
        override
    {
        require(amountSpecified > 0, "amountSpecified can only be positive");
        (uint256 minAmountOut, uint256 destChainId, uint256 destVmType) =
            abi.decode(extraData, (uint256, uint256, uint256));

        (uint256 amount0Available, uint256 amount1Available) = balancesAvailable();
        require(
            (zeroForOne ? amount1Available : amount0Available) >= minAmountOut,
            "not enough balance to swap in pool"
        );
        address tokenIn;
        if (zeroForOne) {
            tokenIn = token0;
            usersData[msg.sender].amount0 += uint256(amountSpecified);
            stagedToken0Amount += uint256(amountSpecified);
        } else {
            tokenIn = token1;
            usersData[msg.sender].amount1 += uint256(amountSpecified);
            stagedToken1Amount += uint256(amountSpecified);
        }
        usersData[msg.sender].withdrawAfter = block.timestamp + 10 minutes;
        ActionBox.Action memory action;
        action.actionId = manager.actionBox().getActionId(msg.sender);
        action.kernelAppAddress = kernelManager;
        action.kernelAppCalldata = abi.encodeWithSignature(
            "swap(bytes)",
            abi.encode(
                action.actionId,
                block.chainid,
                1, // src vmType
                destChainId,
                destVmType,
                _fromAddressToBytes32(recipient),
                kernelPool,
                zeroForOne,
                int256(_normalizeTokenAmount(uint256(amountSpecified), tokenIn)),
                sqrtPriceLimitX96,
                extraData
            )
        );
        action.user = _fromAddressToBytes32(msg.sender);
        manager.actionBox().createAction(action);
        IERC20(tokenIn).transferFrom(msg.sender, address(this), uint256(amountSpecified));

        manager.eventEmitter().swapped(
            address(this), kernelPool, msg.sender, zeroForOne, amountSpecified, sqrtPriceLimitX96
        );
    }

    function settleSwap(
        address user,
        uint256 amount0ToTransfer,
        uint256 amount1ToTransfer,
        uint256 amount0ToSettle,
        uint256 amount1ToSettle
    )
        external
        override
        onlyGateway
    {
        _settle(
            user,
            _denormalizeTokenAmount(amount0ToSettle, token0),
            _denormalizeTokenAmount(amount1ToSettle, token1)
        );
        _transferTo(user, amount0ToTransfer, amount1ToTransfer);
    }

    function changeKernelAddresses(
        address _kernelManager,
        address _kernelPool
    )
        external
        onlyGateway
    {
        kernelManager = _kernelManager;
        kernelPool = _kernelPool;
    }

    // temporary function. to be removed before prod deployment
    function executeArbCall(address to, bytes memory callData) external onlyGateway {
        Address.functionCall(to, callData);
    }

    function _fromAddressToBytes32(address addr) private pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function _normalizeTokenAmount(uint256 amount, address token) private view returns (uint256) {
        return amount * 10 ** (NORMALIZED_DECIMAL - IERC20Metadata(token).decimals());
    }

    function _denormalizeTokenAmount(
        uint256 amount,
        address token
    )
        private
        view
        returns (uint256)
    {
        return amount / 10 ** (NORMALIZED_DECIMAL - IERC20Metadata(token).decimals());
    }

    function _settle(address user, uint256 amount0, uint256 amount1) private {
        // to avoid under flow due to possible precision mismatch
        stagedToken0Amount = stagedToken0Amount > amount0 ? stagedToken0Amount - amount0 : 0;
        stagedToken1Amount = stagedToken1Amount > amount1 ? stagedToken1Amount - amount1 : 0;

        UserData storage userData = usersData[user];
        userData.amount0 = userData.amount0 > amount0 ? userData.amount0 - amount0 : 0;
        userData.amount1 = userData.amount1 > amount1 ? userData.amount1 - amount1 : 0;
    }

    function _transferTo(address user, uint256 amount0, uint256 amount1) internal {
        uint256 amount0Denormalized = _denormalizeTokenAmount(amount0, token0);
        uint256 amount1Denormalized = _denormalizeTokenAmount(amount1, token1);
        (uint256 amount0Available, uint256 amount1Available) = balancesAvailable();
        require(
            amount0Denormalized <= amount0Available && amount1Denormalized <= amount1Available,
            "not enough balance to transfer in pool"
        );
        IERC20(token0).transfer(user, amount0Denormalized);
        IERC20(token1).transfer(user, amount1Denormalized);
    }
}
