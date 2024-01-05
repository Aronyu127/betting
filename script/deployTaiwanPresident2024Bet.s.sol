// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {TaiwanPresident2024BetCondition} from "../src/TaiwanPresident2024BetCondition.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {Betting} from "../src/Betting.sol";

contract deployTaiwanPresident2024BetConditionScript is Script {
    address constant WETH = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
    address constant LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    IERC20 public link;
    function setUp() public {}
    function run() public {
        uint privateKey = vm.envUint("MAINNET_PRIVATE_KEY");
        vm.startBroadcast(privateKey);
        link = IERC20(LINK);
        TaiwanPresident2024BetCondition condition = new TaiwanPresident2024BetCondition();
        link.transfer(address(condition), 1 * 10 ** 18);
        Betting betting = new Betting(address(WETH), address(condition));

        vm.stopBroadcast();
    }
}
// forge script --rpc-url https://sepolia.gateway.tenderly.co script/deployTaiwanPresident2024Bet.s.sol:deployTaiwanPresident2024BetConditionScript --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast
// forge verify-contract 0xF68737cCd429049df80476912006334bAD2464E4 src/Bet.sol:Bet --watch --chain-id 11155111 --constructor-args "0000000000000000000000007b79995e5f793a07bc00c21412e50ecae098e7f9000000000000000000000000571f342a54cf52c1edcc27e1e2414601d2a2395d"
