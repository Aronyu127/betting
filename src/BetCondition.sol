// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

abstract contract BetCondition {
    uint256 end_time;
    modifier ended() {
        require(block.timestamp >= end_time, "Bet has not ended");
        _;
    }
    function getAnswer() external virtual returns (bool){}

    function endTime() external view returns (uint256) {
        return end_time;
    }
}
