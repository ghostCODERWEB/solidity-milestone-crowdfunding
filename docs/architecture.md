# Architecture

## Domain

Goal-based token funding with contributor-weighted milestone approvals, beneficiary releases and failure refunds.

## Trust and economic model

A successful campaign locks unapproved funds indefinitely unless future milestones gain majority approval. There is no contributor rage-quit or beneficiary guarantee. Weight equals historical contribution; milestone votes require a strict majority of total funding. Failed campaigns refund principal.

## Components

`MilestoneCrowdfund` holds domain state and exposes transitions. `SuiteBase` provides two-step ownership, pause control and reentrancy protection to administrative suites. `AssetFlow` verifies exact incoming token balance changes and performs checked native payouts. OpenZeppelin supplies token standards, math, safe transfers, Merkle verification and NFT reception.

`test/contracts/TestAssets.sol` contains unrestricted mint helpers, a fee-burning token and a rejecting native receiver. These are excluded from the deployment guide's primary contract and must never be used as real assets.

## Units and timing

All amounts are base units. ERC20 decimals are not automatically normalized. Timestamps use block.timestamp in seconds; tests advance the local chain explicitly. Integer operations round down except where OpenZeppelin defines standard ERC4626 rounding. Externally supplied amounts must account for dust and slippage.

## Failure semantics

A failed precondition or external transfer reverts the whole transaction. Accounting and settlement flags revert with it. Events report completed transitions. Off-chain clients should verify successful receipts and retain relevant event IDs.

## Build reproducibility

Pinned npm dependencies, exact compiler version, optimizer settings and explicit Cancun EVM target. Compilation includes storage layouts and deployed-bytecode size validation against EIP-170. Generated build output is not committed.
