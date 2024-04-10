// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {DeployRankedChoiceVoting} from "../script/DeployRankedChoiceVoting.s.sol";
import {HelperRankedChoiceVoting} from "./HelperRankedChoiceVoting.t.sol";
import {RankedChoiceVoting} from "../src/RankedChoiceVoting.sol";

// Simple test suite that tests the RankedChoiceVoting contract. This suite does not include gas price for simplicity reasons

contract RankedChoiceVotingTest is HelperRankedChoiceVoting {
    uint256 constant CANDIDATE_COUNT = 4;

    function setUp() external {
        DeployRankedChoiceVoting deployRankedChoiceVoting = new DeployRankedChoiceVoting();
        s_rankedChoiceVoting = deployRankedChoiceVoting.run();
    }

    function testGetCandidates() public view {
        assertEq(s_rankedChoiceVoting.getCandidates()[0], "David");
        assertEq(s_rankedChoiceVoting.getCandidates()[1], "Eve");
        assertEq(s_rankedChoiceVoting.getCandidates()[2], "Frank");
        assertEq(s_rankedChoiceVoting.getCandidates()[3], "Igor");
    }

    function testSuccessfulVote() public {
        string[] memory ballotAlice = new string[](CANDIDATE_COUNT);
        ballotAlice[0] = "David";
        ballotAlice[1] = "Eve";
        ballotAlice[2] = "Frank";
        ballotAlice[3] = "Igor";

        vm.startPrank(ALICE);
        vm.expectEmit(true, true, true, true);
        emit RankedChoiceVoting.Voted(ALICE);
        s_rankedChoiceVoting.vote(ballotAlice);
        assertEq(s_rankedChoiceVoting.getVoteCount(), 1);
        vm.stopPrank();
    }

    function testWrongBallotVote() public {
        string[] memory ballot = new string[](CANDIDATE_COUNT + 1);
        ballot[0] = "David";
        ballot[1] = "Eve";
        ballot[2] = "Frank";
        ballot[3] = "Igor";
        ballot[4] = "WrongCandidate";

        assertGt(ballot.length, s_rankedChoiceVoting.getCandidates().length);

        vm.startPrank(ALICE);
        vm.expectRevert("Wrong number of candidates");
        s_rankedChoiceVoting.vote(ballot);
        vm.stopPrank();
    }

    function testHasAlreadyVotedVote() public {
        string[] memory ballotAlice = new string[](CANDIDATE_COUNT);
        ballotAlice[0] = "David";
        ballotAlice[1] = "Eve";
        ballotAlice[2] = "Frank";
        ballotAlice[3] = "Igor";

        vm.startPrank(ALICE);
        s_rankedChoiceVoting.vote(ballotAlice);

        vm.expectRevert("Already voted");
        s_rankedChoiceVoting.vote(ballotAlice);
        vm.stopPrank();
    }

    function testHasDuplicates() public {
        string[] memory ballot = new string[](CANDIDATE_COUNT);
        ballot[0] = "David";
        ballot[1] = "Eve";
        ballot[2] = "Frank";
        ballot[3] = "David";

        vm.startPrank(ALICE);
        vm.expectRevert("Ballot contains duplicates");
        s_rankedChoiceVoting.vote(ballot);
        vm.stopPrank();
    }

    // function testTallyFullMajority() public {
    //     string memory expectedWinner = "David";

    //     string[] memory ballotAlice = new string[](CANDIDATE_COUNT);
    //     ballotAlice[0] = "David";
    //     ballotAlice[1] = "Eve";
    //     ballotAlice[2] = "Frank";
    //     ballotAlice[3] = "Igor";
    //     voteFor(ALICE, ballotAlice);

    //     string[] memory ballotBob = new string[](3);
    //     ballotBob[0] = "David";
    //     ballotBob[1] = "Frank";
    //     ballotBob[2] = "Igor";
    //     voteFor(BOB, ballotBob);

    //     string[] memory ballotCharles = new string[](3);
    //     ballotCharles[0] = "Eve";
    //     ballotCharles[1] = "Igor";
    //     ballotCharles[2] = "Frank";
    //     voteFor(CHARLES, ballotCharles);

    //     assertEq(s_rankedChoiceVoting.getVoteCount(), 3);

    //     vm.expectEmit(true, true, true, true);
    //     emit RankedChoiceVoting.Tallied(expectedWinner);
    //     s_rankedChoiceVoting.tally();

    //     assertEq(s_rankedChoiceVoting.getWinner(), expectedWinner);
    // }

    function testTally() public {
        string memory expectedWinner = "David";

        string[] memory ballotAlice = new string[](CANDIDATE_COUNT);
        ballotAlice[0] = "David";
        ballotAlice[1] = "Eve";
        ballotAlice[2] = "Frank";
        ballotAlice[3] = "Igor";
        voteFor(ALICE, ballotAlice);

        string[] memory ballotBob = new string[](CANDIDATE_COUNT);
        ballotBob[0] = "David";
        ballotBob[1] = "Frank";
        ballotBob[2] = "Igor";
        ballotBob[3] = "Eve";
        voteFor(BOB, ballotBob);

        string[] memory ballotCharles = new string[](3);
        ballotCharles[0] = "Frank";
        ballotCharles[1] = "David";
        ballotCharles[2] = "Igor";
        voteFor(CHARLES, ballotCharles);

        string[] memory ballotGeorge = new string[](3);
        ballotGeorge[0] = "Eve";
        ballotGeorge[1] = "David";
        ballotGeorge[2] = "Frank";
        voteFor(GEORGE, ballotGeorge);

        string[] memory ballotHarry = new string[](2);
        ballotHarry[0] = "Frank";
        ballotHarry[1] = "David";
        voteFor(HARRY, ballotHarry);

        assertEq(s_rankedChoiceVoting.getVoteCount(), 5);

        vm.expectEmit(true, true, true, true);
        emit RankedChoiceVoting.Tallied(expectedWinner);
        s_rankedChoiceVoting.tally();

        assertEq(s_rankedChoiceVoting.getWinner(), expectedWinner);
    }

    function testTallyOtherCase() public {
        string memory expectedWinner = "Frank";

        string[] memory ballotAlice = new string[](CANDIDATE_COUNT);
        ballotAlice[0] = "David";
        ballotAlice[1] = "Eve";
        ballotAlice[2] = "Frank";
        ballotAlice[3] = "Igor";
        voteFor(ALICE, ballotAlice);

        string[] memory ballotBob = new string[](CANDIDATE_COUNT);
        ballotBob[0] = "Frank";
        ballotBob[1] = "David";
        ballotBob[2] = "Igor";
        ballotBob[3] = "Eve";
        voteFor(BOB, ballotBob);

        string[] memory ballotCharles = new string[](3);
        ballotCharles[0] = "Frank";
        ballotCharles[1] = "David";
        ballotCharles[2] = "Igor";
        voteFor(CHARLES, ballotCharles);

        string[] memory ballotGeorge = new string[](3);
        ballotGeorge[0] = "Eve";
        ballotGeorge[1] = "David";
        ballotGeorge[2] = "Frank";
        voteFor(GEORGE, ballotGeorge);

        string[] memory ballotHarry = new string[](2);
        ballotHarry[0] = "Igor";
        ballotHarry[1] = "David";
        voteFor(HARRY, ballotHarry);

        assertEq(s_rankedChoiceVoting.getVoteCount(), 5);

        // vm.expectEmit(true, true, true, true);
        // emit RankedChoiceVoting.Tallied(expectedWinner);
        s_rankedChoiceVoting.tally();

        assertEq(s_rankedChoiceVoting.getWinner(), expectedWinner);
    }
}
