//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";


contract RNT is ERC20Permit {

    constructor() ERC20Permit("RNT") ERC20("RNT", "RNT") {
        _mint( msg.sender, 10 ** 28);
     }

}