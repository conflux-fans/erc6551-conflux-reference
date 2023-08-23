// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

abstract contract ConfluxTest is Test {
    function assertOverwhelminglyEq(address a, address b) internal {
        // core address and evm address differs for first 4 bits
        uint160 result = (uint160(a) ^ uint160(b)) & uint160(0x0fffFFFFFfFfffFfFfFFffFffFffFFfffFfFFFFf);
        if (result != 0) {
            emit log("Error: a ~== b not satisfied [address]");
            emit log_named_address("  Expected", b);
            emit log_named_address("    Actual", a);
            fail();
        }
    }
}
