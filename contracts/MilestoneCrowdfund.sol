// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Milestone token crowdfunding
/// @notice Goal-based token funding with contributor-weighted milestone approvals, beneficiary releases and failure refunds.
/// @dev Reference implementation; independent audit required before production.

contract MilestoneCrowdfund is SuiteBase {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;
    address public immutable beneficiary;
    uint64 public immutable deadline;
    uint256 public immutable goal;
    uint256 public totalRaised;
    uint256 public remaining;
    uint256 public nextMilestone;
    bool public fundingFinalized;
    bool public successful;
    mapping(address => uint256) public contribution;
    struct Milestone {
        uint256 amount;
        uint256 votes;
        uint64 voteEnd;
        bool executed;
    }
    mapping(uint256 => Milestone) public milestones;
    mapping(uint256 => mapping(address => bool)) public voted;
    event Contributed(address indexed contributor, uint256 amount);
    event FundingFinalized(bool successful, uint256 raised);
    event MilestoneCreated(uint256 indexed id, uint256 amount, uint64 voteEnd);
    event Released(uint256 indexed id, uint256 amount);
    constructor(
        address asset,
        address receiver,
        uint64 end,
        uint256 target,
        address admin
    ) SuiteBase(admin) {
        require(
            asset.code.length > 0 &&
                receiver != address(0) &&
                end > block.timestamp &&
                target > 0,
            "config"
        );
        token = IERC20(asset);
        beneficiary = receiver;
        deadline = end;
        goal = target;
    }
    function contribute(uint256 amount) external nonReentrant whenNotPaused {
        require(
            block.timestamp < deadline && !fundingFinalized,
            "funding ended"
        );
        AssetFlow.pullExact(token, msg.sender, amount);
        contribution[msg.sender] += amount;
        totalRaised += amount;
        remaining += amount;
        emit Contributed(msg.sender, amount);
    }
    function finalizeFunding() external {
        require(block.timestamp >= deadline && !fundingFinalized, "finalize");
        fundingFinalized = true;
        successful = totalRaised >= goal;
        emit FundingFinalized(successful, totalRaised);
    }
    function refund() external nonReentrant {
        require(fundingFinalized && !successful, "refund unavailable");
        uint256 amount = contribution[msg.sender];
        require(amount > 0, "contribution");
        contribution[msg.sender] = 0;
        remaining -= amount;
        token.safeTransfer(msg.sender, amount);
    }
    function proposeMilestone(
        uint256 amount,
        uint64 duration
    ) external returns (uint256 id) {
        require(
            msg.sender == beneficiary &&
                fundingFinalized &&
                successful &&
                amount > 0 &&
                amount <= remaining &&
                duration > 0,
            "milestone"
        );
        id = ++nextMilestone;
        milestones[id] = Milestone(
            amount,
            0,
            uint64(block.timestamp) + duration,
            false
        );
        emit MilestoneCreated(id, amount, uint64(block.timestamp) + duration);
    }
    function approveMilestone(uint256 id) external {
        Milestone storage m = milestones[id];
        require(
            m.amount > 0 &&
                !m.executed &&
                block.timestamp < m.voteEnd &&
                contribution[msg.sender] > 0 &&
                !voted[id][msg.sender],
            "vote"
        );
        voted[id][msg.sender] = true;
        m.votes += contribution[msg.sender];
    }
    function release(uint256 id) external nonReentrant {
        Milestone storage m = milestones[id];
        require(
            m.amount > 0 &&
                !m.executed &&
                block.timestamp >= m.voteEnd &&
                m.votes > totalRaised / 2 &&
                m.amount <= remaining,
            "release"
        );
        m.executed = true;
        remaining -= m.amount;
        token.safeTransfer(beneficiary, m.amount);
        emit Released(id, m.amount);
    }
}
