# 🌳 Merkle Airdrop

A secure **Merkle Tree based token airdrop system** built using **Foundry** and **Solidity**.

This project demonstrates:

- ✅ ERC20 token creation
- ✅ Merkle tree based whitelisting
- ✅ EIP-712 typed signatures
- ✅ Secure token claiming
- ✅ Off-chain proof generation
- ✅ Foundry scripting/testing workflow

***

## 📌 Project Overview

The project allows **only whitelisted users** to claim ERC20 tokens.

Instead of storing all eligible addresses on-chain (which is expensive), the contract stores only a **single Merkle Root**.

Eligible users prove membership in the whitelist using:
- **Merkle Proofs**
- **EIP-712 signatures**

This architecture is used in real-world crypto projects because it is:
- ⛽ Gas efficient
- 📈 Scalable
- 🔐 Secure

***

## 🧠 Core Concepts

### 1. Merkle Trees

A Merkle Tree is a cryptographic tree where:
- **Leaf nodes** = hashed user data
- **Parent nodes** = hashes of child nodes
- **Final top hash** = Merkle Root

**Example leaf:**
```solidity
keccak256(abi.encode(user, amount))
```

**Tree structure:**
```
        Root
       /    \
    HashAB  HashCD
    /   \    /   \
   A     B  C     D
```

The smart contract stores only:
```solidity
bytes32 merkleRoot;
```

When a user claims:
1. They provide a **proof**
2. Contract **reconstructs the root**
3. If roots match → claim succeeds

> This avoids storing huge address lists on-chain.

***

### 2. Merkle Proofs

A proof is the set of **sibling hashes** needed to reconstruct the Merkle Root.

**Example:** If user `C` claims:

- Proof may contain:
  - `hash(D)`
  - `hash(AB)`
- Contract reconstructs:
  - `H(C, D)`
  - `H(AB, CD)` → Root

If reconstructed root equals stored root → **user is verified**.

***

### 3. EIP-712 Signatures

This project also uses **EIP-712 typed structured signatures**.

**Why?**
- Prevents unauthorized claiming
- Proves the claimer owns the wallet
- Protects against replay/malicious claims

**User signs:**
```
AirdropClaim(address account, uint256 amount)
```

**Contract verifies using:**
```solidity
ECDSA.tryRecover(...)
```

***

## 🏗️ Project Architecture

```
User
  ↓
Frontend / Script
  ↓
Gets Merkle Proof + Signature
  ↓
Calls claim()
  ↓
Contract verifies:
   ├── proof
   ├── signature
   └── claim status
  ↓
Tokens transferred
```

***

## 📁 File Structure

```
├── src/
│   ├── LuffyToken.sol
│   └── MerkleAirdrop.sol
├── script/
│   ├── DeployMerkleAirdrop.s.sol
│   ├── GenerateInput.s.sol
│   ├── MakeMerkle.s.sol
│   ├── Interaction.s.sol
│   └── target/
│       ├── input.json
│       └── output.json
└── test/
    └── MerkleAirdrop.t.sol
```

***

### `src/LuffyToken.sol`

ERC20 token contract.

**Features:**
- Token Name: `Luffy`
- Symbol: `LUFFY`
- Owner-controlled minting

**Main functionality:**
```solidity
mint(address to, uint256 amount)
```
- Only owner can mint new tokens.

**Uses:**
- OpenZeppelin `ERC20`
- OpenZeppelin `Ownable`

***

### `src/MerkleAirdrop.sol`

Main airdrop contract.

**Responsibilities:**
- Stores Merkle Root
- Verifies proofs
- Verifies EIP-712 signatures
- Prevents double claims
- Transfers tokens

#### `claim()`

```solidity
claim(
    address account,
    uint256 amount,
    bytes32[] calldata proof,
    uint8 v,
    bytes32 r,
    bytes32 s
)
```

**Verifies:**
1. User has not already claimed
2. Signature is valid
3. Merkle proof is valid

Then transfers tokens.

#### `getMessage()`

Generates EIP-712 digest. Used for signing messages off-chain.

***

### `script/DeployMerkleAirdrop.s.sol`

Deployment script.

**Deploys:**
- `LuffyToken`
- `MerkleAirdrop`

**Flow:**
1. Deploy token
2. Deploy airdrop contract
3. Mint tokens
4. Fund airdrop contract

***

### `script/GenerateInput.s.sol`

Generates Merkle tree input JSON.

**Creates:**
```json
{
  "types": [...],
  "count": ...,
  "values": ...
}
```

Contains whitelist addresses and claim amounts. This simulates backend-generated whitelist data.

***

### `script/MakeMerkle.s.sol`

**Generates:**
- Merkle Root
- Merkle Proofs
- Leaf hashes

**Uses:**
- `Murky`
- `stdJson`

**Workflow:**
1. Reads `input.json`
2. Hashes leaves
3. Builds Merkle Tree
4. Computes proofs
5. Writes `output.json`

**Important hashing logic:**
```solidity
keccak256(
    bytes.concat(
        keccak256(ltrim64(abi.encode(data)))
    )
)
```

***

### `script/Interaction.s.sol`

Claim interaction script.

**Responsibilities:**
- Fetch deployed airdrop contract
- Split ECDSA signature
- Call `claim()`

**Uses:**
- `DevOpsTools.get_most_recent_deployment()`

***

### `test/MerkleAirdrop.t.sol`

Complete Foundry test suite.

**Tests:**
- Valid claim flow
- Signature generation
- Token transfers
- Proof verification

**Important concepts demonstrated:**
- `vm.sign()`
- `vm.prank()`
- EIP712 digest signing
- zkSync compatibility

***

## 🔒 Security Features

### Double Claim Protection

```solidity
mapping(address => bool) claimed;
```

Prevents users from claiming twice.

### Signature Verification

Ensures:
- Claimer owns the wallet
- Claims cannot be spoofed

### Merkle Proof Verification

Ensures:
- Only whitelisted users claim
- Amount cannot be modified

***

## 🛠️ Technologies Used

| Technology | Purpose |
|---|---|
| [Foundry](https://getfoundry.sh/) | Smart contract development & testing |
| Solidity 0.8.24 | Smart contract language |
| [OpenZeppelin Contracts](https://openzeppelin.com/contracts/) | ERC20 & Ownable base contracts |
| [Murky](https://github.com/dmfxyz/murky) | Merkle tree generation |
| EIP-712 | Typed structured data signing |
| ECDSA | Signature recovery |
| Forge Std | Foundry testing utilities |

***

## 🚀 Installation

### 1. Clone Repository

```bash
git clone <YOUR_REPO_URL>
cd Airdrop
```

### 2. Install Foundry

**Linux/macOS:**
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

**Windows PowerShell:**
```powershell
irm https://foundry.paradigm.xyz | iex
foundryup
```

### 3. Install Dependencies

```bash
forge install
```

Or manually:
```bash
forge install OpenZeppelin/openzeppelin-contracts
forge install cyfrin/foundry-devops
forge install dmfxyz/murky
forge install foundry-rs/forge-std
```

***

## 🔨 Usage

### Compile Project

```bash
forge build
```

### Run Tests

```bash
forge test -vv
```

### Start Local Anvil Node

```bash
anvil
```

### Generate Merkle Input

```bash
forge script script/GenerateInput.s.sol
```

### Generate Merkle Tree + Proofs

```bash
forge script script/MakeMerkle.s.sol
```

**Generated files:**
```
script/target/input.json
script/target/output.json
```

### Deploy Contracts

```bash
forge script script/DeployMerkleAirdrop.s.sol \
  --rpc-url http://localhost:8545 \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

### Claim Airdrop

```bash
forge script script/Interaction.s.sol:ClaimAirdrop \
  --rpc-url http://localhost:8545 \
  --private-key <PRIVATE_KEY> \
  --broadcast
```

***

## 🧰 Useful Commands

### Check Token Balance

```bash
cast call <TOKEN_ADDRESS> \
  "balanceOf(address)" \
  <USER_ADDRESS> \
  --rpc-url http://localhost:8545
```

***

## 📜 License

This project is licensed under the [MIT License](LICENSE).

***

> Built with  using Foundry & Solidity