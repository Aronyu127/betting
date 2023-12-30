// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {TaiwanPresident2024BetCondition} from "../src/TaiwanPresident2024BetCondition.sol";

contract TaiwanPresident2024BetConditionTest is Test {
    function setUp() public {
        string memory rpc = vm.envString("SEPOLIA_RPC_URL");
        vm.createSelectFork(rpc);
    }

    function test_getAnswer() public {
        TaiwanPresident2024BetCondition condition = new TaiwanPresident2024BetCondition();
        //Add Link Token to use Oracle
        deal(address(0x779877A7B0D9E8603169DdbD7836e478b4624789), address(condition), 10 * 10 ** 18);

        vm.expectRevert("Bet Condition has not ended");
        condition.getAnswer();

        vm.warp(condition.endTime() + 1);
        vm.expectRevert("Result not set yet");
        condition.getAnswer();
        
        //set result to 1
        vm.store(address(condition), bytes32(uint256(12)), bytes32(uint256(1)));
        assertEq(condition.getAnswer(), true);

        //set result to 2
        vm.store(address(condition), bytes32(uint256(12)), bytes32(uint256(2)));
        assertEq(condition.getAnswer(), false);
    }
}
