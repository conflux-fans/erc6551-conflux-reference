// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminSafe {
    constructor() payable {
        address(0x0888000000000000000000000000000000000000).call(
            abi.encodeWithSignature("setAdmin(address,address)", address(this), address(0x0))
        );
    }
}
