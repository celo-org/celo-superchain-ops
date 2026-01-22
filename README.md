# Celo SuperchainOps

Repository created to be equivalent of Optimism SuperchainOps, but for Celo Mainnet

### Purpose

For a detailed explanation of the purpose of this tool, the smart contracts involved, and the upgrade process, please see [PURPOSE.md](./PURPOSE.md).

## Installation

This repository uses [Mise](https://mise.jdx.dev/) to manage dependencies (forge, just, go, etc.) without affecting your system installations.

### Quick Start

```bash
# 1. Install and activate Mise
./scripts/install-mise.sh
# Follow the output instructions to activate mise in your shell, then restart terminal

# 2. Install dependencies
mise trust
mise install
just install-eip712sign

# 3. Configure environment
cp .env.sample .env
# Edit .env and set RPC_URL to an Ethereum mainnet RPC endpoint
```

<details>
<summary>Detailed Mise Setup Instructions</summary>

After running `./scripts/install-mise.sh`, you'll see instructions like:

```bash
echo "eval \"\$(~/.local/bin/mise activate zsh)\"" >> ~/.zshrc
```

Follow these instructions for your shell, then restart your terminal or run `source ~/.zshrc`.

</details>

## Current Release: OpSuccinct v1.0.2 Upgrade

This section outlines the process for signing the Celo Mainnet OpSuccinct v1.0.2 upgrade. As a signer, you are approving the transaction that will execute this upgrade on-chain.

**Previous upgrades:** The v2, v3 (Isthmus), and succinct (v1.0.0) upgrades have been successfully executed. This repository now supports individual upgrades on a per-release basis.

### What is the OpSuccinct v1.0.2 Upgrade?

The OpSuccinct v1.0.2 upgrade updates Celo Mainnet's fault proof system with the latest **OP Succinct v1.0.2** implementation. This upgrade:

1. **Fixes potential proving failures** for blocks that reference L1 blocks with large excess blob gas
2. **Reduces on-chain costs by 9x** through concurrent range splitting proof generation in the succinct-proposer
3. **Registers newly deployed contracts** that were deployed using deterministic CREATE3:
   - `AccessManager` at `0xF59a19c5578291cB7fd22618D16281aDf76f2816`: Manages permissions for the OP Succinct system
   - `OPSuccinctFaultDisputeGame` at `0xc5bd131ceaeb72f15c66418bc2668332ab99de37`: Implements ZK-proof based dispute resolution (v1.0.2)

The contracts were deployed using CREATE3 deterministic deployment. The governance proposal you're signing registers these upgraded contracts with the DisputeGameFactory.

### Upgrade Workflow Status

This signing phase is part of a larger upgrade process:

- ✅ **Pre-calculate deployment addresses** using CREATE3 deterministic deployment
- ✅ **Deploy OpSuccinct v1.0.2 contracts** to pre-calculated addresses with finalized parameters
  - AccessManager: `0xF59a19c5578291cB7fd22618D16281aDf76f2816`
  - OPSuccinctFaultDisputeGame: `0xc5bd131ceaeb72f15c66418bc2668332ab99de37`
- ✅ **Generate upgrade calldata** with initBond set to 0.01 ETH
- ✅ **Simulate upgrade** locally, on forked network, and in Tenderly vnet
- ✅ **Prepare signing infrastructure** and test with this repository
- 🔄 **Gather signatures from multisig signers** ← **You are here**
- ⏳ **Execute governance proposal** to register OP Succinct v1.0.2 games in DisputeGameFactory
- ⏳ **Switch to OP Succinct v1.0.2 proposer** for improved proof generation

### Summary for Signers

#### What You're Signing

A governance proposal to register pre-deployed OpSuccinct v1.0.2 contracts with DisputeGameFactory:

**Update implementation:** OPSuccinctFaultDisputeGame at `0xc5bd131ceaeb72f15c66418bc2668332ab99de37`

#### Pre-Deployed Contracts (Already on Mainnet)

- **AccessManager:** [`0xF59a19c5578291cB7fd22618D16281aDf76f2816`](https://etherscan.io/address/0xF59a19c5578291cB7fd22618D16281aDf76f2816)
- **OPSuccinctFaultDisputeGame:** [`0xc5bd131ceAEb72F15C66418bc2668332AB99DE37`](https://etherscan.io/address/0xc5bd131ceAEb72F15C66418bc2668332AB99DE37)

See [addresses/succinct-v102.json](./addresses/succinct-v102.json) for details.

#### How to Verify

```bash
# Decode calldata to see exact operations
./scripts/decode_succinct-v102_calldata.sh

# Simulate in Tenderly
just simulate succinct-v102

# Verify bytecode (see section below for full instructions)
./scripts/compare_succinct-v102.sh /path/to/op-succinct/contracts/out
```

#### Signing Process

1. Run: `just sign_ledger succinct-v102 [clabs|council] [eth|celo] <index>`
2. Sign on your Ledger device
3. Verify the `out.json` file contains your correct account address
4. Send `out.json` to the facilitator (cLabs)

**Notes:**
- 📍 Default path: Ethereum (`m/44'/60'/<index>'/0/0`)
- 📱 Celo app: See [Ledger workaround](#ledger-workaround-for-celo-app-users)
- 🔗 Nested multisig: Add address as final parameter (see examples below)

### Verification Options

<details>
<summary><strong>Option 1: Decode Calldata</strong> (View exact operations)</summary>

```bash
./scripts/decode_succinct-v102_calldata.sh
```

This shows:
- **setImplementation:** gameType=42, impl=0xc5bd131ceaeb72f15c66418bc2668332ab99de37

</details>

<details>
<summary><strong>Option 2: Simulate in Tenderly</strong> (Visual confirmation)</summary>

```bash
just simulate succinct-v102
```

Displays simulation URL showing governance proposal execution. Enable "Dev" mode in Tenderly UI for best results.

See [TENDERLY.md](./TENDERLY.md) for detailed verification guide.

</details>

<details>
<summary><strong>Option 3: Verify Bytecode</strong> (Check on-chain contracts)</summary>

Contracts are deployed using CREATE3 deterministic deployment.

```bash
# Clone and build op-succinct contracts
git clone https://github.com/celo-org/op-succinct
cd op-succinct && git checkout v1.0.2
cd contracts && forge build

# Compare on-chain bytecode with artifacts
cd /path/to/celo-superchain-ops
./scripts/compare_succinct-v102.sh /path/to/op-succinct/contracts/out
```

This verifies on-chain bytecode matches compiled artifacts.

</details>


### Sign the Transaction

```bash
# 👥 Council team
just sign_ledger succinct-v102 council [eth|celo] <index>

# 🏢 cLabs team
just sign_ledger succinct-v102 clabs [eth|celo] <index>
```

**Examples:**

<details open>
<summary>📝 <strong>Regular Signing (Majority)</strong></summary>

```bash
# Default account (index 0)
just sign_ledger succinct-v102 clabs eth

# Specific account index
just sign_ledger succinct-v102 council eth 1
```

</details>

<details>
<summary>🔗 <strong>Nested Multisig (Mento)</strong></summary>

For signers of nested multisigs within Security Council:

```bash
just sign_ledger succinct-v102 council eth 0 0xMentoMultisigAddress
```

Replace `0xMentoMultisigAddress` with your nested multisig address.

</details>

---

**After signing:** ✅ Verify `out.json` contains your correct address, then send to facilitator.

### Ledger Workaround for Celo App Users

The Celo Ledger app does not support signing EIP-712 typed data, which is required for this process. However, there is a workaround using the "Eth Recovery" app on your Ledger.

**Steps for Ledger Live (to get Eth Recovery app):**
1. Open Ledger Live
2. Settings → Experimental Features → Developer Mode
3. Plug in Ledger and unlock
4. Go to My Ledger menu
5. Search in App Catalog for "Eth Recovery"
6. If no app found, check if ledger is prompting to upgrade firmware. If so, upgrade and return to step 5.
7. Install Eth Recovery App

**Steps for Transaction Signing:**

Connect as you usually would to the Safe using Celo terminal, but instead of opening the Celo App, have the Eth Recovery App open on your Ledger device.

You can use `celo` as the ledger app parameter, but you need to have the Eth Recovery App open on your device for the signing to succeed.

```bash
just sign_ledger succinct-v102 clabs celo 1
```

## Command Reference

<details>
<summary>📝 <strong>sign_ledger</strong> - Main signing command</summary>

```bash
just sign_ledger <version> <team> <ledger_app> [account_index] [grand_child]
```

| Parameter | Options | Default | Description |
|-----------|---------|---------|-------------|
| `version` | `succinct-v102`, `succinct`, `v2`, `v3` | - | Upgrade version |
| `team` | `clabs`, `council` | - | Your team |
| `ledger_app` | `eth`, `celo` | - | Ledger app |
| `account_index` | `0`, `1`, `2`... | `0` | Account index |
| `grand_child` | `0x...` | - | 🔗 Nested multisig address |

**Derivation paths:**
- `eth`: `m/44'/60'/<index>'/0/0`
- `celo`: `m/44'/52752'/<index>'/0/0`

</details>

<details>
<summary>🔧 <strong>sign</strong> - Custom HD path</summary>

```bash
just sign <version> <team> [hd_path] [grand_child]
```

| Parameter | Options | Default | Description |
|-----------|---------|---------|-------------|
| `version` | `succinct-v102`, `succinct`, `v2`, `v3` | - | Upgrade version |
| `team` | `clabs`, `council` | - | Your team |
| `hd_path` | Custom path | - | Derivation path (e.g., `m/44'/60'/1'/0/0`) |
| `grand_child` | `0x...` | - | 🔗 Nested multisig address |

For advanced users needing non-standard derivation paths. Must escape special characters.

</details>

<details>
<summary>🔍 <strong>simulate</strong> - Tenderly simulation</summary>

```bash
just simulate <version>
```

| Parameter | Options | Description |
|-----------|---------|-------------|
| `version` | `succinct-v102`, `succinct`, `v2`, `v3` | Upgrade version to simulate |

Displays Tenderly simulation URLs showing contract deployment and governance proposal execution.

</details>

## Execution Flow

1. **Signers** → Sign proposal and send `out.json` to facilitator
2. **Facilitator** → Collects signatures and performs child multisig approvals (cLabs + Security Council)
3. **Child Multisigs** → Approve execution on parent multisig
4. **Parent Multisig** → Executes transaction:
   - `DisputeGameFactory.setImplementation(42, 0xc5bd131ceaeb72f15c66418bc2668332ab99de37)`
5. **Post-Execution** → Switch to OP Succinct v1.0.2 proposer

**Note:** Contracts are already deployed on mainnet ([addresses/succinct-v102.json](./addresses/succinct-v102.json)). This proposal updates the implementation to v1.0.2.
