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

## Current Release: Jovian Upgrade (v4 + v5 + succ-v2)

This upgrade bundles three transactions that must be signed together:

| TX | Version | Description |
|----|---------|-------------|
| 1 | **v4** | Proxy implementation upgrade |
| 2 | **v5** | Proxy implementation upgrade |
| 3 | **succ-v2** | Register new OPSuccinctFaultDisputeGame + transfer SystemConfig ownership |

**Previous upgrades:** v2, v3 (Isthmus), succ-v1 (OpSuccinct v1.0.0), and succ-v102 (OpSuccinct v1.0.2) have been executed.

### What You're Signing

Three governance proposals executed via the parent multisig:

1. **v4** and **v5**: Proxy implementation upgrades via OPCM (`upgrade()`)
2. **succ-v2**: Multicall3 batch that:
   - Calls `setImplementation(42, impl)` on DisputeGameFactory — registers the new `OPSuccinctFaultDisputeGame` at [`0xE7bd695d6A17970A2D9dB55cfeF7F2024d630aE1`](https://etherscan.io/address/0xE7bd695d6A17970A2D9dB55cfeF7F2024d630aE1)
   - Calls `transferOwnership(newOwner)` on SystemConfig — transfers ownership to cLabs Safe

See [addresses/mainnet/07-succ-v2.json](./addresses/mainnet/07-succ-v2.json) for deployed contract addresses.

### Signing Process

Use `sign_all_ledger` to sign all three transactions in one flow:

```bash
just sign_all_ledger <team> <ledger_app> [account_index] [grand_child]
```

This signs v4, v5, and succ-v2 sequentially and produces three output files:
- `out-v4.json`
- `out-v5.json`
- `out-succ-v2.json`

**Send all three files to the facilitator.**

#### Examples

```bash
# Council team, Ethereum app, default account
just sign_all_ledger council eth

# cLabs team, Ethereum app, account index 1
just sign_all_ledger clabs eth 1

# Council team with nested multisig (e.g. Mento)
just sign_all_ledger council eth 0 0xMentoMultisigAddress
```

To sign a single version individually:
```bash
just sign_ledger v4 clabs eth
just sign_ledger succ-v2 council eth 0 0xMentoMultisigAddress
```

### Tenderly Simulations

All three transactions have been simulated on a Tenderly fork of Ethereum mainnet:

```bash
# Show all simulation links
just simulate

# Show a specific version
just simulate v4
```

| Version | Tenderly Simulation |
|---------|---------------------|
| v4 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0x962ef321746bb075a44226bdd645b469e761fb7dbdeb42869902b6e7ebc3b7ef) |
| v5 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0x833bca6071ad1cf1c82acbb58fccefe75e06978454431c0597819cb743363bbb) |
| succ-v2 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0xce7dc169f6885f8ca937135a562068e3444e6c7fc299ffb7e2341372ed006dda) |

### Verification

```bash
# Decode v4 calldata (OPCM upgrade)
cast calldata-decode "upgrade((address,address,bytes32)[],bool)" \
  $(jq -r '.calldata' upgrades/mainnet/05-v4.json)

# Decode v5 calldata (OPCM upgrade)
cast calldata-decode "upgrade((address,address,bytes32)[],bool)" \
  $(jq -r '.calldata' upgrades/mainnet/06-v5.json)

# Decode succ-v2 calldata (Multicall3 aggregate3)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/07-succ-v2.json)
```

All three upgrades have been executed and verified on **Sepolia** prior to mainnet signing.

### Ledger Workaround for Celo App Users

The Celo Ledger app does not support signing EIP-712 typed data. Use the "Eth Recovery" app instead:

1. Open Ledger Live → Settings → Experimental Features → Developer Mode
2. My Ledger → Search "Eth Recovery" → Install
3. Open the Eth Recovery app on your Ledger before signing

```bash
just sign_all_ledger clabs celo 1
```

## Command Reference

<details open>
<summary><strong>sign_all_ledger</strong> - Sign all Jovian transactions (v4 + v5 + succ-v2)</summary>

```bash
just sign_all_ledger <team> <ledger_app> [account_index] [grand_child]
```

| Parameter | Options | Default | Description |
|-----------|---------|---------|-------------|
| `team` | `clabs`, `council` | - | Your team |
| `ledger_app` | `eth`, `celo` | - | Ledger app |
| `account_index` | `0`, `1`, `2`... | `0` | Account index |
| `grand_child` | `0x...` | - | Nested multisig address |

Produces `out-v4.json`, `out-v5.json`, `out-succ-v2.json`.

</details>

<details>
<summary><strong>sign_ledger</strong> - Sign a single version</summary>

```bash
just sign_ledger <version> <team> <ledger_app> [account_index] [grand_child]
```

| Parameter | Options | Default | Description |
|-----------|---------|---------|-------------|
| `version` | `v2`, `v3`, `v4`, `v5`, `succ-v1`, `succ-v102`, `succ-v2` | - | Upgrade version |
| `team` | `clabs`, `council` | - | Your team |
| `ledger_app` | `eth`, `celo` | - | Ledger app |
| `account_index` | `0`, `1`, `2`... | `0` | Account index |
| `grand_child` | `0x...` | - | Nested multisig address |

**Derivation paths:**
- `eth`: `m/44'/60'/<index>'/0/0`
- `celo`: `m/44'/52752'/<index>'/0/0`

</details>

<details>
<summary><strong>sign</strong> / <strong>sign_all</strong> - Custom HD path variants</summary>

```bash
just sign_all <team> [hd_path] [grand_child]
just sign <version> <team> [hd_path] [grand_child]
```

For advanced users needing non-standard derivation paths.

</details>

## Execution Flow

1. **Signers** → Run `just sign_all_ledger` and send `out-v4.json`, `out-v5.json`, `out-succ-v2.json` to facilitator
2. **Facilitator** → Collects signatures and performs child multisig approvals (cLabs + Security Council)
3. **Child Multisigs** → Approve execution on parent multisig
4. **Parent Multisig** → Executes each transaction (v4, v5, succ-v2) sequentially
