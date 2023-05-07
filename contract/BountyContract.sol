// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./sha1.sol";

contract DehashBountyContract {

    struct BountyStruct {

        // Information about hash
        string hashString;
        uint256 hashcatID;
        bytes preHash;
        bool solved;

        // Information about bounty
        uint256 bountyStaked;

        // Information about hash locker
        address bountyLockedBy;
        uint lockedUntilBlock;

    }
    mapping(uint256 => BountyStruct) public bountyList;
    uint256 nextSubmitId = 0;

    

    // Create Bounty
    function createHashBounty(string calldata bountyHash, uint256 hashcatID) public payable  {
        bountyList[nextSubmitId].hashString = bountyHash;
        bountyList[nextSubmitId].hashcatID = hashcatID;
        bountyList[nextSubmitId].bountyStaked += msg.value;

        bountyList[nextSubmitId].lockedUntilBlock = 0;
        bountyList[nextSubmitId].solved = false;

        nextSubmitId += 1;
    }


    // Raise Bounty
    function raiseHashBounty(uint256 id) public payable  {
        bountyList[id].bountyStaked += msg.value;
    }


    // Lock Bounty
    function lockHashBounty(uint256 id) public returns(bool ret) {
        if(bountyList[id].lockedUntilBlock < block.number){
            bountyList[id].bountyLockedBy = msg.sender;
            bountyList[id].lockedUntilBlock = block.number + 100;
            return true;
        }
        return false;
    }


    // Take Bounty
    function takeHashBounty(uint256 id, bytes calldata preHash) public returns(bool ret) {
        address payable bountyReceiver = payable(bountyList[id].bountyLockedBy);

        if(bountyList[nextSubmitId].solved){
            return false;
        }


        

        if(bountyList[id].hashcatID == 100){
            if( keccak256(abi.encodePacked(bountyList[id].hashString)) ==
                keccak256(bytes(iToHex(bytes.concat(SHA1.sha1(preHash)))))
            ){
                bountyList[id].preHash = preHash;
                bountyList[id].bountyStaked = 0;
                bountyReceiver.transfer( bountyList[id].bountyStaked );
            }
        }
    }





    function readString(uint256 id) public view returns(string memory ret) {
        return bountyList[id].hashString;
    }


    function totalBalance() public view returns(uint256 ret) {
        return address(this).balance;
    }


    function checkHash(uint256 id, bytes memory preHash) public view returns(bool) {
        if  ( keccak256(abi.encodePacked(bountyList[id].hashString)) == 
                keccak256(bytes(iToHex(bytes.concat(SHA1.sha1(preHash)))))
            ){
            return true;
        }
        return false;
    }





    function iToHex(bytes memory buffer) public pure returns (string memory) {
        bytes memory converted = new bytes(buffer.length * 2);
        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }
        return string(abi.encodePacked("", converted));
    }


}
