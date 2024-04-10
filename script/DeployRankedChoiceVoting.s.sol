// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {RankedChoiceVoting} from "../src/RankedChoiceVoting.sol";

contract DeployRankedChoiceVoting is Script {
    string[] candidates = ["David", "Eve", "Frank", "Igor"];

    function run() external returns (RankedChoiceVoting) {
        vm.startBroadcast();
        RankedChoiceVoting rankedChoiceVoting = new RankedChoiceVoting(candidates);
        vm.stopBroadcast();
        return rankedChoiceVoting;
    }
}
