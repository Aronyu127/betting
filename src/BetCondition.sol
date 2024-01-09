// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";
abstract contract BetCondition {
    uint256 end_time;
    uint256 stop_bet_time;
    string public description;
    modifier ended() {
        require(block.timestamp >= end_time, "Bet Condition has not ended");
        _;
    }

    function getAnswer() external virtual ended returns (bool){}

    function endTime() external view returns (uint256) {
        return end_time;
    }

    function stopBetTime() external view returns (uint256) {
        return stop_bet_time;
    }

    function getDescription() external view returns (string memory) {
        return description;
    }
}
