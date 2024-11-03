// 题目#1
// 编写一个质押挖矿合约，实现如下功能:
// 1.用户随时可以质押项目方代币 RNT(自定义的ERC20)，开始赚取项目方Token(esRNT);
// 2.可随时解押提取已质押的 RNT;
// 3.可随时领取esRNT奖励，每质押1个RNT每天可奖励 1eSRNT;
// 4.esRNT 是锁仓性的 RNT,1eSRNT 在 30 天后可兑换 1RNT，随时间线性释放，支持提前将 esRNT 兑换成 RNT，但锁定部分将被 burn 燃烧掉。

// 实现功能(用户端操作):
// 质押RNT
// 取消质押RNT,提取出RNT
// 完成兑换:eSRNT为RNT，并提取出来对应数量的RNT，但提前解锁需要燃烧掉锁定部分的esRNT


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract RNT is ERC20Permit {

    constructor() ERC20Permit("RNT") ERC20("RNT", "RNT") {
        _mint( msg.sender, 10 ** 28);
     }

}

contract esRNT is ERC20 {
    
    struct LockInfo {
        address user;
        uint256 amount;
        uint256 lockTime;
    }
    
    LockInfo[] public locks;
    RNT public rnt;
    Stake public stake;

    constructor(address _rnt,address _stake) ERC20("esRNT", "esRNT") {
        rnt = RNT(_rnt);
        stake = Stake(_stake);
    }

    modifier onlyStakeowner {
        require(msg.sender == address(stake), "Onlyowner: only stake owner can call this function");
        _;
    }

    function mint(address to, uint256 amount) external onlyStakeowner {
        // 给用户铸造esRNT
        _mint(to, amount);
        // 记录锁仓信息
        locks.push(LockInfo({
            user: to,
            amount: amount,
            lockTime: block.timestamp
        }));
    }

    function redeem(uint256 id) external {
        require(id < locks.length, "Invalid lock ID");
        LockInfo storage lockInfo = locks[id];
        require(lockInfo.user == msg.sender, "Not the lock owner");

        // 计算解锁的数量
        uint256 timePassed = block.timestamp - lockInfo.lockTime;
        uint256 unlocked = lockInfo.amount * timePassed / 30 days;
 
        if (unlocked > lockInfo.amount) {
            unlocked = lockInfo.amount; // 防止超过锁定数量
        }

        // 转移解锁的RNT给用户
        rnt.transfer(lockInfo.user, unlocked);
        // 销毁未解锁的部分
        uint256 lockedAmount = lockInfo.amount - unlocked;
        if (lockedAmount > 0) {
            rnt.transfer(address(0x0000000000000000000000000000000000000000), lockedAmount);
        }

        // 销毁esRNT
        _burn(msg.sender, lockInfo.amount);

        // 清理锁仓信息
        delete locks[id];
    }

}



contract Stake {

    RNT public rnt;
    esRNT public esrnt;
    uint256 public constant rewardPerSecond = 1.15741 * 10 ** 13;
    uint256 public totalStaked;
    uint256 public totalRewards;

    struct StakeInfo {
        uint256 amount;
        uint256 unclaimed;
        uint256 rewards;
        uint256 lastUpdateTime;
    }

    mapping(address => StakeInfo) public stakeInfo;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 amount);

    constructor(address _rnt, address _esrnt) {
        rnt = RNT(_rnt);
        esrnt = esRNT(_esrnt);
    }

    function stake(uint256 amount) public {
        require(amount > 0, "Stake: amount must be greater than 0");
        require(rnt.balanceOf(msg.sender) >= amount, "Stake: not enough RNT");
        StakeInfo storage info = stakeInfo[msg.sender];
        info.unclaimed += calculateRewards(msg.sender);
        info.lastUpdateTime = block.timestamp;
        info.amount += amount;
        totalStaked += amount;
        rnt.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(amount > 0, "Stake: amount must be greater than 0");
        StakeInfo storage info = stakeInfo[msg.sender];
        require(info.amount >= amount, "Stake: not enough staked");
        info.amount -= amount;
        totalStaked -= amount;
        info.unclaimed += calculateClaimed(msg.sender);
        info.lastUpdateTime = block.timestamp;
        rnt.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claim() public {
        StakeInfo storage info = stakeInfo[msg.sender];
        require(info.amount > 0, "Stake: no staked");
        uint256 rewards = calculateRewards(msg.sender);
        require(rewards > 0, "Stake: no rewards");
        info.rewards += rewards;
        totalRewards += rewards;
        info.lastUpdateTime = block.timestamp;
        info.unclaimed = 0;
        rnt.approve(address(esrnt), rewards);
        esrnt.mint(msg.sender, rewards);
        emit Claimed(msg.sender, rewards);
    }

    function calculateClaimed(address user) internal view returns (uint256) {
        StakeInfo storage info = stakeInfo[user];
        uint256 timePassed = block.timestamp - info.lastUpdateTime;
        return (info.amount * timePassed * rewardPerSecond) / 1e18;
    }

    function calculateRewards(address user) internal view returns (uint256) {
        StakeInfo storage info = stakeInfo[user];
        uint256 timePassed = block.timestamp - info.lastUpdateTime;
        uint256 rewards = info.unclaimed + (info.amount * timePassed * rewardPerSecond) / 1e18;
        return rewards;
    }

 }

