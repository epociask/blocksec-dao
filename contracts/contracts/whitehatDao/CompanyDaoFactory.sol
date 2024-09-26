// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./companyDao.sol";
import "./HackerSolBound.sol";

contract CompanyDaoFactory is Ownable {

    CompanyDao[] companyDaos;

    function createCompanyDao(string memory title, string memory description, address companyWalletAddress, address hackerSBT) public onlyOwner{

        require(IHackerSBT(hackerSBT).balanceOf(companyWalletAddress) == 0, "User must have 0 SBT's to register");

        CompanyDao newDao = new CompanyDao(title, description, companyWalletAddress);

        IHackerSBT(hackerSBT).safeMintCompany(companyWalletAddress);
        companyDaos.push(newDao);
    }

    function getCompanyDaos() public view returns (CompanyDao[] memory){
        return companyDaos;
    }

    function getMyCompanyDaos() public view returns (CompanyDao[] memory){
        uint256 length;
        for (uint i = 0; i < companyDaos.length; i++) {
            CompanyDao cd = CompanyDao(companyDaos[i]);
            if(cd.addressOfCompany() == msg.sender){
                length +=1;
            }
        }

        CompanyDao[] memory myCompanyDaos = new CompanyDao[](length);

        uint j=0;
        for (uint i = 0; i < companyDaos.length; i++) {
            CompanyDao cd = CompanyDao(companyDaos[i]);
            if(cd.addressOfCompany() == msg.sender){
                myCompanyDaos[j] = companyDaos[i];
                j+=1;
            }

        }
        return myCompanyDaos;
    }

}