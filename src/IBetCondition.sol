// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IBetCondition {
    function get_answer(uint256 time) external view returns (bool);
}
