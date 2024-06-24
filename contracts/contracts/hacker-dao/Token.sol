    // SPDX-License-Identifier: UNLICENSED
    pragma solidity ^0.8.13;
    import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
    import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

    import "./IBounty.sol";

    library Lib {

        struct WhStakeReceipt {
            uint256 amount;
            uint256 unlockTime;
            uint256 submissionTime;
        }

        struct ownerStakeRegister {
            uint256 amount;
            uint256 unlockTime;
            uint256 deducted;

        }
    }

    contract WhiteHatToken is ERC20, Ownable {
        mapping(address => mapping(address => mapping(bytes32 => Lib.WhStakeReceipt))) stakeRegistry;

        uint8 constant maxAccountLocks = 10;
        uint256 minimumStake;

        constructor(uint256 initialSupply, uint256 _minimumStake, address owner) ERC20("WhiteHat", "WHT") {
            _mint(msg.sender, initialSupply);
            _transferOwnership(owner);
            
            minimumStake = _minimumStake;
        }

        function changeMinimumStake(uint256 newAmount) public onlyOwner {
            minimumStake = newAmount;
        }

        // stakeBountySubmission ... stakes a
        function stakeBountySubmission(address account, uint256 amount, address bountyAddress, bytes32 vulnID) public onlyOwner {
            require(amount >= minimumStake, "Minimum stake is not above minimumStake value");
            
            // Burn amounts 
            _transfer(account, address(0), amount);

            Lib.WhStakeReceipt memory entry = Lib.WhStakeReceipt(amount, IBounty(bountyAddress).getEndTime(), block.timestamp);
            // Update entry into stake regsistry
            stakeRegistry[bountyAddress][account][vulnID] = entry; 

            emit Transfer(account, address(0), amount);
        }

        // function stakeBounty(uint256 amount, address bountyAddress) {
        //     require(msg.sender != IBounty(bountyAddress).owner(), "Caller must be bounty owner");

        //     _transfer(account, address(0), amount);
            

        // }

        function slashStake(address account, address bountyAddress, bytes32 vulnID) public onlyOwner { 
            require(stakeRegistry[bountyAddress][account][vulnID].amount > 0, "No stake entry for provided parameters");

            delete stakeRegistry[bountyAddress][account][vulnID];
        }

        function claimStake(address account, address bountyAddress, bytes32 vulnID) external {
            require(stakeRegistry[bountyAddress][account][vulnID].amount > 0, "No stake entry for provided parameters");
            require(stakeRegistry[bountyAddress][account][vulnID].unlockTime >= block.timestamp, "Stake is not unlocked yet");

            // Mint funds back to user
            _transfer(address(0), account, stakeRegistry[bountyAddress][account][vulnID].amount);
        }
    }