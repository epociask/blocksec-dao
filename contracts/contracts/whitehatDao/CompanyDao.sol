// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./bounty.sol";

contract CompanyDao is Ownable {

    string public title;

    // Can be in IPFS and handled via UI to make it more versatile. if we have time to change later.
    string public description;

    // stores bounties
    // also, solidity funkiness for this mapping
    address[] bounties;

    address public addressOfCompany;

    constructor(string memory _title, string memory _description, address _addressOfCompany){

        require(bytes(_title).length > 0, "title cannot be empty");
        require(bytes(_description).length > 0, "description cannot be empty");
        require(_addressOfCompany == address(_addressOfCompany), "address of company is invalid");

        title = _title;
        description = _description;
        addressOfCompany = _addressOfCompany;
    }

    function getBounties() public view returns (address[] memory){
        uint256 length;
        for (uint i = 0; i < bounties.length; i++) {
            Bounty cdc = Bounty(bounties[i]);
            if(uint(cdc.getStatus()) == 0){
                length +=1;
            }
        }

        address[] memory activeBounties = new address[](length);

        uint j=0;
        for (uint i = 0; i < bounties.length; i++) {
            Bounty cdc = Bounty(bounties[i]);
            if(uint(cdc.getStatus()) == 0){
                activeBounties[j] = bounties[i];
                j+=1;
            }

        }
        return activeBounties;
    }

    function bountyExists(address bounty) public view returns (bool) {
        for (uint i = 0; i < bounties.length; i++) {
            if (bounties[i] == bounty) {
                return true;
            }
        }
        return false;
    }

    function registryBounty(address bountyAddress) public {
        require(bountyExists(bountyAddress) == false, "Bounty already reigstered.");
        bounties.push(payable(bountyAddress));
    }

    function updateTitle(string memory newTitle) public onlyOwner {
        title = newTitle;
    }

    function updateDescription(string memory newDescription) public onlyOwner {
        description = newDescription;
    }

    function updateAddressOfCompany(address newAddressOfCompany) public onlyOwner {
        addressOfCompany = newAddressOfCompany;
    }

}