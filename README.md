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

## Active Release: succ-v201 (OPSuccinctFaultDisputeGame impl update)

The Jovian upgrade (v4 + v5 + succ-v2) has been executed on mainnet. The next standalone proposal re-registers a new `OPSuccinctFaultDisputeGame` implementation for game type `42`.

| Version | Description | Source |
|---------|-------------|--------|
| **succ-v201** | Register new OPSuccinctFaultDisputeGame on DisputeGameFactory (game type 42) | Currently in a private repository for a GHSA, contact us to get added to that repository. |

**Previous upgrades (executed):** v2, v3 (Isthmus), succ-v1 (OpSuccinct v1.0.0), succ-v102 (OpSuccinct v1.0.2), v4, v5, and succ-v2.

### What You're Signing

A single governance proposal executed via the parent multisig:

- **succ-v201**: Multicall3 batch that calls `setImplementation(42, impl)` on DisputeGameFactory — registers the new `OPSuccinctFaultDisputeGame` at [`0xA35d2A7F365b42EcFCB7Db9240c3973Fc8e65139`](https://etherscan.io/address/0xA35d2A7F365b42EcFCB7Db9240c3973Fc8e65139).

See [addresses/mainnet/09-succ-v201.json](./addresses/mainnet/09-succ-v201.json) for the deployed contract address and [upgrades/mainnet/09-succ-v201.json](./upgrades/mainnet/09-succ-v201.json) for the calldata.

### Signing Process

Sign with `sign_ledger`:

```bash
just sign_ledger succ-v201 <team> <ledger_app> [account_index] [grand_child]
```

This produces `out.json` — **send it to the facilitator.**

#### Examples

```bash
# Council team, Ethereum app, default account
just sign_ledger succ-v201 council eth

# cLabs team, Ethereum app, account index 1
just sign_ledger succ-v201 clabs eth 1

# Council team with nested multisig (e.g. Mento)
just sign_ledger succ-v201 council eth 0 0xMentoMultisigAddress
```

### Tenderly Simulations

```bash
# Show all simulation links
just simulate

# Show a specific version
just simulate succ-v201
```

| Version | Tenderly Simulation |
|---------|---------------------|
| succ-v201 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/6044ea35-ad95-4d0c-8440-135ccb38ba95/tx/0x0b1d4c6376df347fc937439862c65aebaa4dcb693ed785e3202f1591a4c88bcf) |

Historical executed-upgrade simulations (v4, v5, succ-v2) remain registered in `justfile` for reference.

### Verification

```bash
# Decode succ-v201 calldata (Multicall3 aggregate3)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/09-succ-v201.json)
```

succ-v201 should be verified on **Sepolia** prior to mainnet signing.

### Ledger Workaround for Celo App Users

The Celo Ledger app does not support signing EIP-712 typed data. Use the "Eth Recovery" app instead:

1. Open Ledger Live → Settings → Experimental Features → Developer Mode
2. My Ledger → Search "Eth Recovery" → Install
3. Open the Eth Recovery app on your Ledger before signing

```bash
just sign_ledger succ-v201 clabs celo 1
```

## Command Reference

<details open>
<summary><strong>sign_ledger</strong> - Sign a single version</summary>

```bash
just sign_ledger <version> <team> <ledger_app> [account_index] [grand_child]
```

| Parameter | Options | Default | Description |
|-----------|---------|---------|-------------|
| `version` | `v2`, `v3`, `v4`, `v5`, `succ-v1`, `succ-v102`, `succ-v2`, `succ-v201` | - | Upgrade version |
| `team` | `clabs`, `council` | - | Your team |
| `ledger_app` | `eth`, `celo` | - | Ledger app |
| `account_index` | `0`, `1`, `2`... | `0` | Account index |
| `grand_child` | `0x...` | - | Nested multisig address |

**Derivation paths:**
- `eth`: `m/44'/60'/<index>'/0/0`
- `celo`: `m/44'/52752'/<index>'/0/0`

</details>

<details>
<summary><strong>sign</strong> - Custom HD path variant</summary>

```bash
just sign <version> <team> [hd_path] [grand_child]
```

For advanced users needing non-standard derivation paths.

</details>

## Execution Flow

1. **Signers** → Run `just sign_ledger succ-v201 <team> <ledger_app>` and send `out.json` to the facilitator
2. **Facilitator** → Collects signatures and performs child multisig approvals (cLabs + Security Council)
3. **Child Multisigs** → Approve execution on the parent multisig
4. **Parent Multisig** → Executes the succ-v201 transaction
