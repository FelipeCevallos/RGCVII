// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
// import "lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

// RaidGuild Cohort VII Governance Token (RGG)  
contract RGCVII is ERC721, ERC20Votes, Ownable, ReentrancyGuard {
    // Mapping from NFT ID to governance token amount
    mapping(uint256 => uint256) public tokenVotingPower;
    
    // Counter for NFT IDs
    uint256 private _tokenIdCounter;

    constructor(address initialOwner) 
        Ownable(initialOwner)
        ERC721("Governance NFT", "gNFT") 
        ERC20("Governance Token", "GOV")
        ERC20Permit("Governance Token") // Required by ERC20Votes
    {}

    // Mint new NFT with associated governance tokens
    function mintNFT(address to, uint256 votingPower) external onlyOwner nonReentrant {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        
        // Mint the NFT
        _safeMint(to, tokenId);
        
        // Mint governance tokens and associate them with the NFT
        _mint(address(this), votingPower);
        tokenVotingPower[tokenId] = votingPower;
    }

    // Allow NFT owner to delegate voting power
    function delegateVotingPower(uint256 tokenId, address delegatee) external {
        require(ownerOf(tokenId) == msg.sender, "Not the NFT owner");
        uint256 votingPower = tokenVotingPower[tokenId];
        _delegate(delegatee);
    }

    // Override transfer functions to handle delegation
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721) {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        
        // Reset delegation when NFT is transferred
        if (from != address(0)) {
            _delegate(from, address(0));
        }
    }

    // Required overrides
    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Votes)
    {
        super._burn(account, amount);
    }

}
