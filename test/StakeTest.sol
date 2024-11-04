// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/RNT.sol";
import "../src/esRNT.sol";
import "../src/Stake.sol";

contract StakeTest is Test {
    Stake public stake;
    RNT public rnt;
    esRNT public esrnt;

    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    function setUp() public {
        rnt = new RNT();
        esrnt = new esRNT(address(rnt));
        stake = new Stake(address(rnt), address(esrnt));

    }   

    function testStake() public {
        // Pledge 2 ether RNT
        rnt.approve(user1, 2 ether);
        rnt.transfer(user1, 2 ether );
        rnt.approve(address(stake), 2 ether);
        vm.startPrank(user1);
        rnt.approve(address(stake), 2 ether);
        stake.stake(2 ether);
        vm.stopPrank();

        //Check pledge information
        (   uint256 amount,
            uint256 unclaimed,
            uint256 rewards,
            uint256 lastUpdateTime
        ) = stake.stakeInfo(user1);
    
        assertEq(amount, 2 ether);
        assertEq(unclaimed, 0);
        assertEq(rewards, 0);
        assertEq(lastUpdateTime, block.timestamp);
    }

    function testUnstake() public {
        // Pledge 2 ether RNT
        rnt.approve(user1, 2 ether);
        rnt.transfer(user1, 2 ether );
        rnt.approve(address(stake), 2 ether);
        vm.startPrank(user1);
        rnt.approve(address(stake), 2 ether);
        stake.stake(2 ether);
        //Cancel staking 1 ether RNT when 1 child was young
        vm.warp(block.timestamp + 1 hours);
        stake.unstake(1 ether);
        vm.stopPrank();

        //Check pledge information
        (   uint256 amount,
            uint256 unclaimed,
            uint256 rewards,
            uint256 lastUpdateTime
        ) = stake.stakeInfo(user1);

        assertEq(amount, 1 ether);
        assertEq(unclaimed, 41666760000000000);
        assertEq(rewards, 0 );
        assertEq(lastUpdateTime, block.timestamp);
    }

    function testClaim() public {
        //Cancel staking 1 ether RNT
        rnt.approve(user1, 2 ether);
        rnt.transfer(user1, 2 ether );
        rnt.approve(address(stake), 2 ether);

        vm.startPrank(user1);
        rnt.approve(address(stake), 2 ether);
        stake.stake(2 ether);

        vm.warp(block.timestamp + 1 hours);

        stake.unstake(1 ether);
        vm.stopPrank();

        //Claim rewards
        vm.startPrank(user1);
        stake.claim();
        vm.stopPrank();

        //Check pledge information
        (   uint256 amount,
            uint256 unclaimed,
            uint256 rewards,
            uint256 lastUpdateTime
        ) = stake.stakeInfo(user1);

        assertEq(amount, 1 ether);
        assertEq(unclaimed, 0);
        assertEq(rewards, 41666760000000000);
        assertEq(lastUpdateTime, block.timestamp);
    }

        function testredeem() public {
        //Pledge 2 ether RNT and take away 1 ether RNT
        rnt.approve(user1, 2 ether);
        rnt.transfer(user1, 2 ether );
        rnt.approve(address(stake), 2 ether);
        vm.startPrank(user1);
        rnt.approve(address(stake), 2 ether);
        stake.stake(2 ether);
        vm.warp(block.timestamp +  1 days );
        stake.unstake(1 ether);
        vm.stopPrank();

        //Claim the corresponding reward esRNT 100000224000000000 RNT
        vm.startPrank(user1);
        stake.claim();
        vm.stopPrank();
        uint256 user1Account_rnt_lock = rnt.balanceOf(user1);

        // 29 days later, redeem the corresponding reward esRNT, which is 96666883200000000 RNT
        // and assert that a change in RNT balance for user 1 has been detected
        vm.warp(block.timestamp + 29 days); 
        rnt.transfer(address(stake), 10 ** 27);
        vm.startPrank(user1);
        stake.redeem(0);
        vm.stopPrank();
        uint256 user1Account_rnt_unlock = rnt.balanceOf(user1);

        assertEq(user1Account_rnt_unlock - user1Account_rnt_lock, 966668832000000000 );
    }

}









