// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console2} from "forge-std/Test.sol";
import {Bet} from "../src/Bet.sol";
import {IBetCondition} from "../src/IBetCondition.sol";

contract BetCondition is IBetCondition {
    function getAnswer(uint256 time) external view override returns (bool) {
        return true;
    }
}

contract BetTest is Test {
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    
    Bet public bet;
    IERC20 public BetToken;
    BetCondition public condition;
    address public user1;
    address public user2;
    address public user3;
    uint256 constant usdc_decimal = 10 ** 6;
    uint256 public endTime;
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
        condition = new BetCondition();
        endTime = block.timestamp + 1000;
        bet = new Bet(address(BetToken), address(condition), endTime);
    }

    function test_bet() public {
      vm.startPrank(user1);
      BetToken.approve(address(bet), 1000 * usdc_decimal);
      bet.bet(1000 * usdc_decimal, true);
      vm.stopPrank();

      vm.startPrank(user2);
      BetToken.approve(address(bet), 900 * usdc_decimal);
      bet.bet(900 * usdc_decimal, false);
      vm.stopPrank();

      vm.startPrank(user3);
      BetToken.approve(address(bet), 500 * usdc_decimal);
      bet.bet(500 * usdc_decimal, true);
      vm.stopPrank();

      assertEq(BetToken.balanceOf(address(bet)), 2400 * usdc_decimal);
      assertEq(bet.yes_bet(user1), 1000 * usdc_decimal);
      assertEq(bet.no_bet(user2), 900 * usdc_decimal);
      assertEq(bet.yes_bet(user3), 500 * usdc_decimal);
    }

    function test_finish_fail() public {
      test_bet();

      vm.expectRevert("Bet has not ended");
      bet.finish();
    }

    function test_finish_with_yes_and_claim() public {
      test_bet();

      vm.warp(endTime + 1);
      bet.finish();

      bet.claim(user1);
      bet.claim(user3);

      assertEq(BetToken.balanceOf(user1), 1600 * usdc_decimal);
      assertEq(BetToken.balanceOf(user3), 800 * usdc_decimal);

      vm.expectRevert("Already claimed");
      bet.claim(user1);
 
      vm.expectRevert("Notthing to claim");
      bet.claim(user2);
    }

    function test_finish_with_false_and_claim() public {
      test_bet();

      vm.warp(endTime + 1);
      bytes memory data = abi.encodeWithSelector(bytes4(keccak256("getAnswer(uint256)")), endTime + 1);
      vm.mockCall(address(condition), data, abi.encode(false));
      bet.finish();

      bet.claim(user2);

      assertEq(BetToken.balanceOf(user2), 2400 * usdc_decimal);

      vm.expectRevert("Already claimed");
      bet.claim(user2);
 
      vm.expectRevert("Notthing to claim");
      bet.claim(user1);
    }
}
