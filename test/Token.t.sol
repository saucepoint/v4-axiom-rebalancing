// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {console} from "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";
import {YiToken} from "../Token.sol";

contract TokenTest is Test {
    YiToken yitoken;

    function setUp() public virtual {
        yitoken = new Yi();
    }

    function testNameIsYi() public {
        assertEq(Yi.name(), "Yi");
    }
}
