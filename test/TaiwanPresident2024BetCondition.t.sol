// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console2} from "forge-std/Test.sol";
import {TaiwanPresident2024BetCondition} from "../src/TaiwanPresident2024BetCondition.sol";

contract TaiwanPresident2024BetConditionTest is Test {
    TaiwanPresident2024BetCondition condition;
    function setUp() public {
        string memory rpc = vm.envString("SEPOLIA_RPC_URL");
        vm.createSelectFork(rpc);
        condition = new TaiwanPresident2024BetCondition();
    }

    function test_getAnswer() public {
        vm.warp(condition.endTime() - 1);
        vm.expectRevert("Bet Condition has not ended");
        condition.getAnswer();

        vm.warp(condition.endTime() + 1);
        vm.expectRevert("Result not set yet");
        condition.getAnswer();
        
        //set result to 1
        vm.store(address(condition), bytes32(uint256(13)), bytes32(uint256(1)));
        assertEq(condition.getAnswer(), true);

        //set result to 2
        vm.store(address(condition), bytes32(uint256(13)), bytes32(uint256(2)));
        assertEq(condition.getAnswer(), false);
    }

    function test_getDescription() public {
        assertEq(condition.getDescription(), "Will Lai Ching-te be the next president of Taiwan?");
    }
}
