// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "forge-std/Test.sol";
import {RankedChoiceVoting} from "../src/RankedChoiceVoting.sol";

abstract contract HelperRankedChoiceVoting is Test {
    RankedChoiceVoting s_rankedChoiceVoting;

    address ALICE = makeAddr("alice");
    address BOB = makeAddr("bob");
    address CHARLES = makeAddr("charles");

    address GEORGE = makeAddr("george");
    address HARRY = makeAddr("harry");

    function voteFor(address user, string[] memory ballot) public {
        vm.startPrank(user);
        s_rankedChoiceVoting.vote(ballot);
        vm.stopPrank();
    }
}
