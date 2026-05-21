// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
contract MakeAirdrop{
    using SafeERC20 for IERC20;

    
    error InvalidProof();
    address[] claimers; 
    bytes32 private immutable I_markleRoot;
    IERC20 private immutable I_token;

    event Claimed(address indexed claimer,uint256 amount);
    constructor(bytes32 markleRoot,IERC20 token){
        I_markleRoot = markleRoot;
        I_token = token;
    }
    function claim(uint256 amount,bytes32[] calldata proof) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender,amount))));
        if(!MerkleProof.verify(proof,I_markleRoot,leaf)){
            revert InvalidProof();
        }
        emit Claimed(msg.sender,amount);
        I_token.safeTransfer(msg.sender,amount);
    }
}