// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {Betting} from "../src/Betting.sol";
import {BetCondition} from "../src/BetCondition.sol";

contract BetConditionInstance is BetCondition {
    constructor() {
        end_time = block.timestamp + 100;
        stop_bet_time = block.timestamp + 50;
        description = "Bet Description";
    }
    function getAnswer() external override returns (bool) {
        return true;
    }
}

contract BettingTest is Test {
    address constant USDC = 0x43506849D7C04F9138D1A2050bbF3A0c054402dd;
    
    Betting public betting;
    IERC20 public BetToken;
    BetConditionInstance public condition_instance;
    address public user1;
    address public user2;
    address public user3;
    uint256 constant usdc_decimal = 10 ** 6;
    uint256 public endTime;
    uint256 public stopBetTime;
    function setUp() public {

        string memory rpc = vm.envString("MAINNET_RPC_URL");
        vm.createSelectFork(rpc);
        BetToken = IERC20(USDC);
        user1 = makeAddr("user1");
        deal(address(BetToken), user1, 1000 * usdc_decimal);
        user2 = makeAddr("user2");
        deal(address(BetToken), user2, 900 * usdc_decimal);
        user3 = makeAddr("user3");
        deal(address(BetToken), user3, 500 * usdc_decimal);
        condition_instance = new BetConditionInstance();
        endTime = condition_instance.endTime();
        stopBetTime = condition_instance.stopBetTime();
        betting = new Betting(address(BetToken), address(condition_instance));
    }

    function test_descritpion() public {
      assertEq(betting.description(), condition_instance.getDescription());
    }

    function test_bet_after_stop_time_fail() public {
      vm.startPrank(user1);
      BetToken.approve(address(betting), 1000 * usdc_decimal);
      vm.expectRevert("Bet has stopped bet");
      vm.warp(stopBetTime + 1);
      betting.bet(1000 * usdc_decimal, true);
      vm.stopPrank();
    }

    function test_bet_after_end_time_fail() public {
      vm.startPrank(user1);
      BetToken.approve(address(betting), 1000 * usdc_decimal);
      vm.expectRevert("Bet has ended");
      vm.warp(endTime + 1);
      betting.bet(1000 * usdc_decimal, true);
      vm.stopPrank();
    }

    function test_bet() public {
      vm.startPrank(user1);
      BetToken.approve(address(betting), 1000 * usdc_decimal);
      betting.bet(1000 * usdc_decimal, true);
      vm.stopPrank();

      vm.startPrank(user2);
      BetToken.approve(address(betting), 900 * usdc_decimal);
      betting.bet(900 * usdc_decimal, false);
      vm.stopPrank();

      vm.startPrank(user3);
      BetToken.approve(address(betting), 500 * usdc_decimal);
      betting.bet(500 * usdc_decimal, true);
      vm.stopPrank();

      assertEq(BetToken.balanceOf(address(betting)), 2400 * usdc_decimal);
      assertEq(betting.yes_bet(user1), 1000 * usdc_decimal);
      assertEq(betting.no_bet(user2), 900 * usdc_decimal);
      assertEq(betting.yes_bet(user3), 500 * usdc_decimal);
    }

    function test_finish_fail() public {
      test_bet();

      vm.expectRevert("Bet has not ended");
      betting.finish();
    }

    function test_finish_with_yes_and_claim() public {
      test_bet();

      vm.warp(endTime + 1);
      betting.finish();

      betting.claim(user1);
      betting.claim(user3);

      assertEq(BetToken.balanceOf(user1), 1600 * usdc_decimal);
      assertEq(BetToken.balanceOf(user3), 800 * usdc_decimal);

      vm.expectRevert("Already claimed");
      betting.claim(user1);
 
      vm.expectRevert("Notthing to claim");
      betting.claim(user2);
    }

    function test_finish_with_false_and_claim() public {
      test_bet();

      vm.warp(endTime + 1);
      bytes memory data = abi.encodeWithSelector(bytes4(keccak256("getAnswer()")));
      vm.mockCall(address(condition_instance), data, abi.encode(false));
      betting.finish();

      betting.claim(user2);

      assertEq(BetToken.balanceOf(user2), 2400 * usdc_decimal);

      vm.expectRevert("Already claimed");
      betting.claim(user2);
 
      vm.expectRevert("Notthing to claim");
      betting.claim(user1);
    }
}
