// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
contract MerkleAirdrop{
    using SafeERC20 for IERC20;


    error InvalidProof();
    error AlreadyClaimed();
    address[] claimers; 
    bytes32 private immutable I_markleRoot;
    IERC20 private immutable I_token;
    mapping(address=>bool) private claimed;
    event Claimed(address indexed claimer,uint256 amount);
    constructor(bytes32 markleRoot,IERC20 token){
        I_markleRoot = markleRoot;
        I_token = token;
    }
    function claim(address account,uint256 amount,bytes32[] calldata proof) external {
        if(claimed[account]){
            revert AlreadyClaimed();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account,amount))));
        if(!MerkleProof.verify(proof,I_markleRoot,leaf)){
            revert InvalidProof();
        }
        claimed[account] = true;
        emit Claimed(account,amount);
        I_token.safeTransfer(account,amount);
    }
    function  getMarkleRoot() external view returns(bytes32){
        return I_markleRoot;
    }
    function getToken() external view returns(IERC20){
        return I_token;
    }
}