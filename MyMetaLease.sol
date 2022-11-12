// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./base/ERC721Base.sol";

contract Lease is ERC721Base {

    mapping(uint256 => address) internal _agreements;
    
    function create(
        IERC721 tokenContract,
        uint256 tokenID,
        address user,
        address agreement
    ) external {
        address tokenOwner = tokenContract.ownerOf(tokenID);
        require(msg.sender == tokenOwner || _operatorsForAll[tokenOwner][msg.sender], "NOT_AUTHORIZED");

        uint256 lease = _leaseIDOrRevert(tokenContract, tokenID);
        address leaseOwner = _ownerOf(lease);
        require(leaseOwner == address(0), "ALREADY_EXISTS");

        _mint(user, lease);
        _agreements[lease] = agreement;
    }

    function destroy(IERC721 tokenContract, uint256 tokenID) external {
        uint256 lease = _leaseID(tokenContract, tokenID);
        address leaseOwner = _ownerOf(lease);
        require(leaseOwner != address(0), "NOT_EXISTS");
        address agreement = _agreements[lease];
        if (agreement != address(0)) {
            require(msg.sender == agreement, "NOT_AUTHORIZED_AGREEMENT");
        } else {
            address tokenOwner = tokenContract.ownerOf(tokenID);
            require(
                msg.sender == leaseOwner ||
                    _operatorsForAll[leaseOwner][msg.sender] ||
                    msg.sender == tokenOwner ||
                    _operatorsForAll[tokenOwner][msg.sender],
                "NOT_AUTHORIZED"
            );
        }
        _burn(leaseOwner, lease);

        _destroySubLeases(lease);
    }

    function getAgreement(uint256 lease) public view returns (address) {
        return _agreements[lease];
    }

    function getAgreement(IERC721 tokenContract, uint256 tokenID) external view returns (address) {
        return getAgreement(_leaseIDOrRevert(tokenContract, tokenID));
    }

    function isLeased(IERC721 tokenContract, uint256 tokenID) external view returns (bool) {
        return _ownerOf(_leaseIDOrRevert(tokenContract, tokenID)) != address(0);
    }

    function currentUser(IERC721 tokenContract, uint256 tokenID) external view returns (address) {
        uint256 lease = _leaseIDOrRevert(tokenContract, tokenID);
        address leaseOwner = _ownerOf(lease);
        if (leaseOwner != address(0)) {
            return _submostLeaseOwner(lease, leaseOwner);
        } else {
            return tokenContract.ownerOf(tokenID);
        }
    }

    function leaseID(IERC721 tokenContract, uint256 tokenID) external view returns (uint256) {
        return _leaseIDOrRevert(tokenContract, tokenID);
    }

    function _leaseIDOrRevert(IERC721 tokenContract, uint256 tokenID) internal view returns (uint256 lease) {
        lease = _leaseID(tokenContract, tokenID);
        require(lease != 0, "INVALID_LEASE_MAX_DEPTH_8");
    }

    function _leaseID(IERC721 tokenContract, uint256 tokenID) internal view returns (uint256) {
        uint256 baseId = uint256(keccak256(abi.encodePacked(tokenContract, tokenID))) &
            0x1FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        if (tokenContract == this) {
            uint256 depth = ((tokenID >> 253) + 1);
            if (depth >= 8) {
                return 0;
            }
            return baseId | (depth << 253);
        }
        return baseId;
    }

}
