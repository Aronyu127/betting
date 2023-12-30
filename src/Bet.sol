// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IBetCondition } from "./IBetCondition.sol";
import {console} from "forge-std/Test.sol";

contract Bet {
  address public erc20_address;
  IERC20 public bet_token;
  address public condition_address;
  IBetCondition public condition;
  uint256 public end_time;
  uint256 public total_bet;
  uint256 public total_yes_bet;
  uint256 public total_no_bet;
  uint256 public remaining_reward;
  mapping(address => uint256) public yes_bet;
  mapping(address => uint256) public no_bet;
  mapping(address => bool) public claim_list;
  uint8 public result;
  event Bet(address indexed better, uint256 amount, bool yes);

  constructor(address _erc20_address, address _condition_address, uint256 _end_time) {
    erc20_address = _erc20_address;
    bet_token = IERC20(_erc20_address);
    condition = IBetCondition(_condition_address);
    condition_address = _condition_address;
    end_time = _end_time;
  }

  modifier ended() {
    require(block.timestamp >= end_time, "Bet has not ended");
    _;
  }
    
  function bet(uint256 amount, bool yes) external {
    require(block.timestamp < end_time, "Bet has ended");
    require(bet_token.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
    require(bet_token.balanceOf(msg.sender) >= amount, "Not enough balance");

    bet_token.transferFrom(msg.sender, address(this), amount);
    total_bet += amount;
    if (yes) {
      yes_bet[msg.sender] += amount;
      total_yes_bet += amount;
    } else {
      no_bet[msg.sender] += amount;
      total_no_bet += amount;
    }
    emit Bet(msg.sender, amount, yes);
  }

  function finish() external ended {
    require(result == 0, "Result has been set");
    result = condition.getAnswer(block.timestamp) ? 1 : 2;
    remaining_reward = result == 1 ? total_no_bet : total_yes_bet;
  }

  function claim(address better) external ended {
    require(result > 0, "Result has not been set");
    require(claim_list[better] != true, "Already claimed");

    uint256 bet_amount = result == 1 ? yes_bet[better] : no_bet[better];
    require(bet_amount > 0, "Notthing to claim");

    uint256 total_reward = result == 1 ? total_no_bet : total_yes_bet;
    uint256 total_bet = result == 1 ? total_yes_bet : total_no_bet;

    uint256 reward = bet_amount * total_reward / total_bet ;
    uint256 claim_amount = bet_amount + reward;

    // console.log("bet_amount: %s", bet_amount);
    // console.log("total_bet: %s", total_bet);
    // console.log("total_reward: %s", total_reward);

    // console.log("reward: %s", reward);
    claim_list[better] = true;
    remaining_reward -= reward;
    bet_token.transfer(better, claim_amount);  
  }
}