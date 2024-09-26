// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Bounty.sol";

contract BountyFactory is Ownable {

    Bounty[] public bountiesCreated;

    function addNewBounty(address bountyHost_, address tokenAddress_, uint256 endTimeStamp_,
        string memory metaDataID_, uint256 maxSubmissions_, string memory title_, string memory description_) public {
        Bounty newBounty = new Bounty(bountyHost_, tokenAddress_, endTimeStamp_, metaDataID_, maxSubmissions_, title_, description_);
        bountiesCreated.push(newBounty);
    }

}