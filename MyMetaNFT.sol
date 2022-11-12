pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyMetaNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    public uint256 _donateId;
    
    constructor() ERC721("MyMetaNFT", "NFT") {}

    uint256 totalSupply = 10000000;

    function mintNFT(address recipient, string memory tokenURI)
        public onlyOwner
    {   
        uint256 i =0;
        for ( i=0;i<totalSupply;i++){
            _tokenIds.increment();

            uint256 newItemId = _tokenIds.current();
            _mint(recipient, newItemId);
            _setTokenURI(newItemId, tokenURI);
        }

    }

    function buyLand(address from, address to, uint _tokenId){
        to.transferFrom(from, _tokenId);
    }

    function sellLand(address from, address to, uint _tokenId){
        from.transferFrom(to, _tokenId);
    }

    function giveDonate(address from, address to, uint _donateId){
        to.transferFrom(from, _donateId);
    }
}


