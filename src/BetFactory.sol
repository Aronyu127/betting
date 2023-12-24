// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import { Bet } from "./Bet.sol";
contract BetFactory {
    function createBetContract(address erc20_token, address condition_contract, uint end_time) public returns (address) {
        Bet newBet = new Bet(erc20_token, condition_contract, end_time);
        return address(newBet);
    }
}
