
# Skate AMM Protocol

Skate AMM is a modular, intent-driven Automated Market Maker (AMM) protocol designed for scalable, multi-chain DeFi applications. Built with Foundry, it leverages a kernel-periphery architecture to enable secure, flexible asset management and cross-chain execution.

## Architecture Overview

- **Kernel Layer**: Core AMM logic, pool management, and event emission. Handles pool creation, liquidity management, and intent processing.
- **Periphery Layer**: Chain-specific interfaces for user interaction, asset staging, and cross-chain execution. Includes managers, pools, and event emitters.
- **Skate Apps**: Extendable contracts for custom logic, intent processing, and integration with external systems.
- **Common Utilities**: Shared libraries for math, token handling, and registry management.

## Key Contracts

### Kernel

- `KernelPool.sol`: Core AMM pool logic, compatible with Uniswap V3 interfaces. Manages swaps, mints, burns, and collects.
- `KernelEventEmitter.sol`: Emits standardized events for pool creation, initialization, and asset actions.
- `IKernelManager.sol`: Manages pools, fees, and periphery pool mapping. Handles intent-driven mint, burn, swap, and protocol fee collection.

### Periphery

- `PeripheryManager.sol`: Manages periphery pools, event emitters, and action boxes. Handles pool creation and fee configuration.
- `PeripheryPool.sol`: User-facing pool contract for asset staging, minting, burning, and swapping. Integrates with kernel pools and manages user balances.
- `Multicall.sol`: Enables batched contract calls for efficient user interactions.

### Skate Apps

- `SkateApp.sol`: Abstract base for intent-driven applications. Manages periphery contract mapping and processes user intents via the `MessageBox`.
- `AccountRegistry.sol`, `AccountStorage.sol`: Manage user accounts and storage for Skate apps.

### Common

- Math and utility libraries: `FullMath.sol`, `LiquidityMath.sol`, `SafeCast.sol`, etc.
- `ExecutorRegistry.sol`: Manages authorized executors for cross-chain task execution.

## Intent-Driven Execution

Skate AMM supports intent-based workflows, allowing users to submit signed intents for asset actions. The `MessageBox` contract emits events for relayers and AVS (Attestation Verification Services) to process and execute tasks across chains.

## Cross-Chain Support

- Periphery contracts are mapped to chain IDs for seamless multi-chain deployment.
- The `SkateGateway` contract acts as the entry point for executing tasks on periphery chains.

## Events & Transparency

All major actions (pool creation, mint, burn, swap, collect) emit standardized events for off-chain monitoring and analytics.

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/) toolkit
- Node.js, npm (for scripting and deployment)

### Build & Test

```sh
forge build
forge test
```

### Deployment

Update deployment scripts and use Foundry's `forge script` for contract deployment.

### Usage

- Interact with pools via periphery contracts.
- Submit intents for cross-chain execution.
- Monitor events for off-chain integrations.

## Documentation

- Contract interfaces are documented in-code.
- See the `src/` directory for detailed contract implementations.

## License

All contracts are licensed under BUSL-1.1 or GPL-2.0-or-later as specified in each file.
