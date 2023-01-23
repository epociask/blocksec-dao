// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library Core {
    // TODO - Investigate additional status states
    enum SubmissionStatus{Review, Accepted, Contested, Rejected}

    struct SubmissionMetaData {
        address whiteHat;
        uint256 vulnStorageID;
        uint256 timeStamp;
        SubmissionStatus status;
    }

    struct Submission {
        SubmissionMetaData metaData;
        bool isValue;
    }
}

contract Bounty is Ownable {
    // TODO - Investigate ways in which to embed governance priveleges
    uint256 public constant minSubmissions = 10;
    uint256 public maxSubmissions;
    uint256 public submissionCount;

    // TODO - Investigate additional status states
    // NOTE - Status is conditionally derived from other state variables
    enum BountyStatus{Active, Closed}

    address public bountyHost;
    address public tokenAddress;

    uint256 public maxPool;
    uint256 public startTime;
    uint256 public endTime;
    bytes32 public metaDataID;
    
    mapping(bytes32 => Core.Submission) public submissions;

    // Initialize contract relevant bounty data fields
    constructor(address bountyHost_, address tokenAddress_, uint256 maxPool_, uint256 endTimeStamp_, bytes32 metaDataID_, uint256 maxSubmissions_) {
        // TODO - Consider specifying minimual bounty active lifetime
        // TODO - Validate metadata ID
        require(endTimeStamp_ > block.timestamp, "End timestamp must be greater than the start timestamp");
        require(maxSubmissions_ >= minSubmissions, "Max submissions should always be greater than minSubmissions");

        bountyHost = bountyHost_;
        tokenAddress = tokenAddress_;

        maxPool = maxPool_;

        startTime = block.timestamp;
        endTime = endTimeStamp_;

        metaDataID = metaDataID_;

        maxSubmissions = maxSubmissions_;
    }

    // getStatus returns the current contract bounty status
    function getStatus() public view returns (BountyStatus) {
        if (block.timestamp >= endTime) {
            return BountyStatus.Closed;
        }

        return BountyStatus.Active; 
    }

    // TODO - Make amount an ERC-20 
    // increasePool increase the current rewards pool
    function increasePool(uint256 amount) public onlyOwner {
        maxPool += amount;
    }

    function increaseDeadline(uint256 newDeadline) public onlyOwner {
        require(newDeadline > endTime, "New deadline cannot be less than the one already set");
        require(getStatus() != BountyStatus.Closed, "Bounty must be active for a deadline to be increased");

        endTime = newDeadline;
    }

    // TODO - Make collatoral an ERC-20 token
    // ** Submission logic functionality **/   
    function submitVulnerability(address beneficiary, uint256 storageID, uint256 collatoral) public returns (bytes32) {
        require(submissionCount <= maxSubmissions-1, "Submission limit has currently been exceeded");
        require(beneficiary != bountyHost, "You cannot submit vulnerabilites as bounty host");

        // TODO - Validate beneficiary has provided collatoral to Data DAO

            // 1 - Instantiate DAO contract

            // 2 - Call DAO contract to lock beneficiary collatoral
            
        // TODO - Add logic to validate storage ID is Filecoin CID using Marketplace APIs
        
        Core.SubmissionMetaData memory metaData_ = Core.SubmissionMetaData(msg.sender, storageID, block.timestamp, Core.SubmissionStatus.Review);
        
        // Compute UID of vulnerability submission
        bytes32 id = sha256(abi.encodePacked(beneficiary, storageID));
        if (submissions[id].isValue) {
            revert("A vulnerability submission has already been made for provided beneficiary x storageID");
        }

        submissions[id] = Core.Submission(metaData_, true);
        submissionCount += 1;

        return id;
    }

    function processSubmission(bytes32 id, Core.SubmissionStatus response) public onlyOwner {
        // TODO - Add challenge deadline logic
        submissions[id].metaData.status = response;
    }

    // TODO - Implement fund recovery / fallback functionality
}


