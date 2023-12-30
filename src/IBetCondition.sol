// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IBetCondition {
    function getAnswer(uint256 time) external returns (bool);
}
