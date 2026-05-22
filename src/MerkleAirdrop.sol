// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
contract MerkleAirdrop is EIP712{
    using SafeERC20 for IERC20;


    error InvalidProof();
    error AlreadyClaimed();
    error InvalidSignature();
    address[] claimers; 
    bytes32 private immutable I_markleRoot;
    IERC20 private immutable I_token;
    mapping(address=>bool) private claimed;

    struct AirdropClaim{
        address account;
        uint256 amount;
    }
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");
    event Claimed(address indexed claimer,uint256 amount);
    constructor(bytes32 markleRoot,IERC20 token) EIP712("MerkleAirdrop","1.0"){
        I_markleRoot = markleRoot;
        I_token = token;
    }
    function claim(address account,uint256 amount,bytes32[] calldata proof,uint8 v,bytes32 r,bytes32 s) external {
        if(claimed[account]){
            revert AlreadyClaimed();
        }
        if(!_isValidSignature(account,getMessage(account,amount),v,r,s)){
            revert InvalidSignature();
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
    function getMessage(address account,uint256 amount) public view returns(bytes32){
        return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim(account,amount))));
    }
    function _isValidSignature(address account,bytes32 digest,uint8 v,bytes32 r,bytes32 s) internal pure returns(bool){
        (address actualSigner, ,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }
}