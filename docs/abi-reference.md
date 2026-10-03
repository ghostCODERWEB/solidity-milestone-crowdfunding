# ABI reference

Generated from the successfully compiled primary contract. Includes inherited OpenZeppelin methods. Authorization requirements and economic semantics are in the Solidity source and architecture guide.

| Signature | Type | Mutability | Return values |
|---|---|---|---|
| `constructor(address asset,address receiver,uint64 end,uint256 target,address admin)` | constructor | nonpayable |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `Contributed(address contributor,uint256 amount)` | event |  |  |
| `FundingFinalized(bool successful,uint256 raised)` | event |  |  |
| `MilestoneCreated(uint256 id,uint256 amount,uint64 voteEnd)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Released(uint256 id,uint256 amount)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `approveMilestone(uint256 id)` | function | nonpayable |  |
| `beneficiary()` | function | view | address  |
| `contribute(uint256 amount)` | function | nonpayable |  |
| `contribution(address )` | function | view | uint256  |
| `deadline()` | function | view | uint64  |
| `finalizeFunding()` | function | nonpayable |  |
| `fundingFinalized()` | function | view | bool  |
| `goal()` | function | view | uint256  |
| `milestones(uint256 )` | function | view | uint256 amount, uint256 votes, uint64 voteEnd, bool executed |
| `nextMilestone()` | function | view | uint256  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `pendingOwner()` | function | view | address  |
| `proposeMilestone(uint256 amount,uint64 duration)` | function | nonpayable | uint256 id |
| `refund()` | function | nonpayable |  |
| `release(uint256 id)` | function | nonpayable |  |
| `remaining()` | function | view | uint256  |
| `renounceOwnership()` | function | nonpayable |  |
| `setPaused(bool value)` | function | nonpayable |  |
| `successful()` | function | view | bool  |
| `token()` | function | view | address  |
| `totalRaised()` | function | view | uint256  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
| `voted(uint256 ,address )` | function | view | bool  |
