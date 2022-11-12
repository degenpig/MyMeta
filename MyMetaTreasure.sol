pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import './Base64.sol';

contract MMTreasure is ERC721Enumerable, ReentrancyGuard, Ownable {
	string[] private asset = [
		"Blox",
		"MMC"
	];

	constructor() ERC721("Treasure", "TREASURE") Ownable(){}

	struct _msgSender {
		uint256 treasureWallet;
	}

	mapping(address => _msgSender) public Gamer;

	function random(string memory input) internal pure returns (uint256){
		return uint256(keccak256(abi.encodePacked(input)));
	}

	function getAsset(uint256, tokenId) public view returns (string memory){
		return pluck(tokenId, "ASSET", asset);
	}

	
	function pluck(uint256 tokenId, string memory keyPrefix, string[] memory sourceArray) internal pure returns (string memory){
		uint256 rand = random(string(abi.encodePacked(keyPrefix, toString(tokenId))));
		if (rand >0.01 && rand < 2.5){
			return rand;
		}
	}

	function giveTreaure(address _msgSender){
		if (asset == 'Blox'){
			Gamer.treaureWallet = rand;
		}
		if (asset == 'MMC'){
			Gamer.treasureWallet = rand * 10000;
		}
	}

	function claim(uint256[] tokenId, uint256 amount) public nonReentrant{
		require(tokenId >0 && tokenId < 9000, "Token ID invalid");
		_safeMint(_msgSender(), tokenId);
		giveTreaure(_msgSender);

	}

	function ownerClaim(uint256[] calldata tokenIds) public nonReentrant onlyOwner{
		address account = owner();

		for (uint i;i<tokenIds.length;i++){
			uint tokenId = tokenIds[i];
			require(tokenId > 8999 && tokenId <10001, "Token ID invalid");
			_safeMint(account, tokenId);
			giveTreaure(_msgSender);
		}
	}

	function toString(uint256 value) internal pure returns (string memory){
		if (value == 0){
			return "0";
		}
		uint256 temp = value;
		uint256 digits;
		while(temp!=0){
			digits++;
			temp/=10;
		}
		bytes memory buffer = new bytes(digits);
		while(value!=0){
			digits -= 1;
			buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
			value /= 10;
		}
		return string(buffer);
	}

	function tokenURI(uint256 tokenId) override public view returns (string memory){
		string[3] memory parts;
		parts[0] = '<svg><rect width="100%" height="100%" fill="gold"/>';
		parts[1] = getAsset(tokenId);
		parts[2] = '</svg>';

		string memory output = string(abi.encodePacked(parts[0],parts[1],parts[2]));
		output = string(abi.encodePacked(output));

		string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name1":"Blox : ' ,toString(tokenId)'","name2":"MMC :',toString(tokenId)'"})));

		output = string(abi.encodePacked('data:application/json;base64,',json));

		return output;

	}
	
}