pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./Bounty.sol";

interface IBounty {
    function getEndTime() external returns (uint256);
    function owner() public view virtual returns (address);
}
