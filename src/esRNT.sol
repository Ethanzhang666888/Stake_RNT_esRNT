//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./RNT.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract esRNT is ERC20 {
    
    struct LockInfo {
        address user;
        uint256 amount;
        uint256 lockTime;
    }
    
    LockInfo[] public locks;
    RNT public rnt;
    address private stakeowner = 0xF62849F9A0B5Bf2913b396098F7c7019b51A820a;
    // The owner of the pledge contract

    constructor(address _rnt) ERC20("esRNT", "esRNT") {
        rnt = RNT(_rnt);

    }

    modifier onlyStakeowner {
        require(msg.sender == address(stakeowner), "Onlyowner: only stake owner can call this function");
        _;
    }

    function mint(address to, uint256 amount) external onlyStakeowner {
        _mint(to, amount);
    }
    
    function burn(address to, uint256 amount) external onlyStakeowner {
        _burn(to, amount);
    }

}