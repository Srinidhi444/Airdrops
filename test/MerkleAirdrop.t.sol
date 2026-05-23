// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test,console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {LuffyToken} from "../src/LuffyToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
contract MerkleAirdropTest is ZkSyncChainChecker, Test {

    MerkleAirdrop public airdrop;
    LuffyToken public token;

    bytes32 private merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    uint256 public constant AMOUNT = 25 * 1e18;
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    address public gaspayer;
    bytes32[] public PROOF = [
        proof1,
        proof2
    ];
    address user;
    uint256 userprivatekey;

    function setUp() public {
        if(!isZkSyncChain()){
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (airdrop,token) = deployer.deployMerkleAirdrop();
        }else{

        token = new LuffyToken();
        token.mint(token.owner(), AMOUNT*4);
        airdrop = new MerkleAirdrop(
            merkleRoot,
            token
        );
        token.transfer(address(airdrop), AMOUNT*4);

        }
        (user, userprivatekey) =
            makeAddrAndKey("user");
        gaspayer = makeAddr("gaspayer");
    }

    function testUsersCanClaim() public {
    uint256 startingBalance =
        token.balanceOf(user);

    bytes32 digest = airdrop.getMessage(user, AMOUNT);
   
    (uint8 v, bytes32 r, bytes32 s) = vm.sign(userprivatekey, digest);
    vm.prank(gaspayer);
    airdrop.claim(user, AMOUNT, PROOF, v, r, s);

    uint256 endingBalance =
        token.balanceOf(user);

    console.log(
        "ending balance: %s",
        endingBalance
    );

    assertEq(
        endingBalance,
        startingBalance + AMOUNT
    );
}
}