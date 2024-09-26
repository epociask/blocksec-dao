pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

library Lib {
    enum Reputation{Noob, Pro, Elite, Wizzard, Buterin}
    enum Role {Hacker, Company, DAOParticipant}
}

interface IHackerSBT {
    function balanceOf(address owner) external view returns (uint256);
    function safeMint(address to, Lib.Role role) external;
    function safeMintCompany(address to) external;
}

contract HackerSoulBound is ERC721, Ownable {

    struct SBTEntry {
        bool isValue;
        Lib.Role role;
        uint256 tokenID;
    }

    using Counters for Counters.Counter;

    mapping(address => SBTEntry) private entries;
    Counters.Counter private _tokenIdCounter;
    address private submissionAuditor;



    constructor(address _submissionAuditorDao) ERC721("WhiteHatSBT", "WHSBT") {
        submissionAuditor = _submissionAuditorDao;
        transferOwnership(submissionAuditor);
    }

    function safeMint(address to, Lib.Role role) external onlyOwner {
        require(to != address(0), "Cannot mint to NULL address");
        require(!entries[to].isValue, "Cannot mint to account with existing SBT entry");

        uint256 _tokenID = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, _tokenID);

        SBTEntry memory entry = SBTEntry(true, role, _tokenID);
        entries[to] = entry;
    }

    function safeMintCompany(address to) external {
        require(to != address(0), "Cannot mint to NULL address");
        require(!entries[to].isValue, "Cannot mint to account with existing SBT entry");

        uint256 _tokenID = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, _tokenID);

        SBTEntry memory entry = SBTEntry(true, Lib.Role.Company, _tokenID);
        entries[to] = entry;
    }

    function getReputation(uint256 tokenId) public view returns (Lib.Reputation) {
        // TODO - Build derivation logic
        return Lib.Reputation.Noob;
    }

    function burn(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Only the owner of the token can burn it.");
        _burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256) pure internal {
        require(from == address(0) || to == address(0), "This a Soulbound token. It cannot be transferred. It can only be burned by the token owner.");
    }

    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    function getUserRole(address user) public view returns (Lib.Role) {
        return entries[user].role;
    }

    function getUserTokenID(address user) public view returns (uint256) {
        return entries[user].tokenID;
    }

}