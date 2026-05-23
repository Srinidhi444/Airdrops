// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 proof1=0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proof2=0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proof1,proof2];
    bytes private SIGNATURE= hex"f4af3a2d36460e9ecf687b0196a8d65e44af2c72efaed6f7fad89f717b40d9d5466d567feb60761116aeeda2dd035bf3e4a29d2b7a8063fea2002412beeb41af1b";

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

    }
    function claimairdrop(address airdrop) public{
    vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
                MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r,s);
    vm.stopBroadcast();
    }
    function run() external {
    address mostRecentDeployment =
        DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);

    claimairdrop(mostRecentDeployment);
}
}