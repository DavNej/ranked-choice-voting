// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {console} from "forge-std/Console.sol";

/**
 * @title RankedChoiceVoting
 * @notice This contract allows for ranked choice voting
 * @dev The contract is initialized with a list of candidates
 */
contract RankedChoiceVoting {
    event Voted(address indexed voter);
    event Tallied(string indexed winner);

    uint256 private voteCount;
    string private winner;
    string[] private candidates;

    mapping(string => uint256[]) private votesPerCandidate;
    mapping(string => uint256) private scorePerCandidate;
    mapping(string => bool) private isCandidateEliminated;
    mapping(address => bool) private hasVoted;

    /// @dev The contract is initialized with a list of candidates
    constructor(string[] memory _candidates) {
        candidates = _candidates;

        /// @dev Initialize votesPerCandidate to prevent out of bounds errors
        for (uint256 i = 0; i < _candidates.length; i++) {
            votesPerCandidate[candidates[i]] = new uint256[](_candidates.length);
        }
    }

    function vote(string[] calldata _candidates) external {
        require(_candidates.length <= candidates.length, "Wrong number of candidates");
        require(!hasVoted[msg.sender], "Already voted");
        require(!_hasDuplicates(_candidates), "Ballot contains duplicates");

        for (uint256 i = 0; i < _candidates.length; i++) {
            string memory candidate = _candidates[i];
            votesPerCandidate[candidate][i] += 1;
        }

        hasVoted[msg.sender] = true;
        voteCount++;

        emit Voted(msg.sender);
    }

    function tally() external returns (string memory) {
        winner = _tally();
        require(
            keccak256(abi.encodePacked(winner)) != keccak256(abi.encodePacked("")),
            "Something went wrong during tallying"
        );

        emit Tallied(winner);
        return winner;
    }

    /// @dev Ideally, this function should only be called by the contract's owner
    function _tally() private returns (string memory) {
        /**
         * @notice Design choice: No draw.
         * @notice The last candidate with the lowest score is eliminated.
         * @notice The last candidate with the highest score is kept.
         * @notice Not fair, but we can change this later
         */
        uint256 votesToRedistribute;
        /// @dev Rounds loop
        for (uint256 round = 0; round < candidates.length; round++) {
            console.log("===============");
            console.log("round", round);

            /// @dev Initialize to first candidate
            uint256 minRoundScore = votesPerCandidate[candidates[0]][round];
            uint256 maxRoundScore;
            string memory roundLooser;
            string memory roundWinner;

            /// @dev Candidates loop
            for (uint256 i = 0; i < candidates.length; i++) {
                string memory candidate = candidates[i];

                if (isCandidateEliminated[candidate]) {
                    continue;
                }

                if (round == 0) {
                    scorePerCandidate[candidate] += votesPerCandidate[candidate][0];
                }

                console.log(candidate, "round:", votesPerCandidate[candidate][round]);
                console.log("total: ", scorePerCandidate[candidate]);

                /// @dev Check if candidate is the winner
                if (_isWinner(candidate)) {
                    return candidate;
                }

                /// @dev Check if the candidate has the lowest score
                if (votesPerCandidate[candidate][round] <= minRoundScore) {
                    minRoundScore = votesPerCandidate[candidate][round];
                    roundLooser = candidate;
                }

                /// @dev Check if the candidate has the highest score
                if (votesPerCandidate[candidate][round] >= maxRoundScore) {
                    maxRoundScore = votesPerCandidate[candidate][round];
                    roundWinner = candidate;
                }
            }

            isCandidateEliminated[roundLooser] = true;
            console.log(roundLooser, "is eliminated");

            votesToRedistribute = minRoundScore;
            console.log(votesToRedistribute, "votes allocated to", roundWinner);

            if (minRoundScore == 0) {
                continue;
            }

            scorePerCandidate[roundWinner] += votesToRedistribute;
            console.log("votesToRedistribute", votesToRedistribute);

            /// @dev Check if candidate is the winner
            if (_isWinner(roundWinner)) {
                return roundWinner;
            }
        }
        revert("No winner");
    }

    function _hasDuplicates(string[] calldata array) public pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            for (uint256 j = i + 1; j < array.length; j++) {
                if (keccak256(abi.encodePacked(array[i])) == keccak256(abi.encodePacked(array[j]))) {
                    return true;
                }
            }
        }

        return false;
    }

    function _isWinner(string memory candidate) private view returns (bool) {
        return 2 * scorePerCandidate[candidate] > voteCount;
    }

    function getWinner() external view returns (string memory) {
        return winner;
    }

    function getCandidates() external view returns (string[] memory) {
        return candidates;
    }

    function getVoteCount() external view returns (uint256) {
        return voteCount;
    }
}
