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

## Active Release: succ-v210 (OPSuccinct v2.1.0 — Hypercube)

A single proposal that updates the `OPSuccinctFaultDisputeGame` implementation for game type `42`, adding Hypercube support. Succeeds succ-v201, which has been executed on mainnet.

| Version | Description | Source |
|---------|-------------|--------|
| **succ-v210** | Update `OPSuccinctFaultDisputeGame` impl on DisputeGameFactory (game type 42) — adds Hypercube | Contact maintainers for source access |

**Previous upgrades (executed):** v2, v3 (Isthmus), succ-v1 (OpSuccinct v1.0.0), succ-v102 (OpSuccinct v1.0.2), v4, v5, succ-v2, and succ-v201.

### What You're Signing

A single governance proposal executed via the parent multisig:

- **succ-v210**: Multicall3 batch that calls `setImplementation(42, impl)` on DisputeGameFactory — registers the new `OPSuccinctFaultDisputeGame` at [`0xfF1caC738a5263736AF258e4b3D6a4970C6351FF`](https://etherscan.io/address/0xfF1caC738a5263736AF258e4b3D6a4970C6351FF).

See [addresses/mainnet/10-succ-v210.json](./addresses/mainnet/10-succ-v210.json) for the deployed contract address and [upgrades/mainnet/10-succ-v210.json](./upgrades/mainnet/10-succ-v210.json) for the calldata.

### Signing Process

Sign with `sign_ledger`:

```bash
just sign_ledger succ-v210 <team> <ledger_app> [account_index] [grand_child]
```

This produces `out.json` — **send it to the facilitator.**

#### Examples

```bash
# Council team, Ethereum app, default account
just sign_ledger succ-v210 council eth

# cLabs team, Ethereum app, account index 1
just sign_ledger succ-v210 clabs eth 1

# Council team with nested multisig (e.g. Mento)
just sign_ledger succ-v210 council eth 0 0xMentoMultisigAddress
```

### Tenderly Simulations

```bash
# Show all simulation links
just simulate

# Show a specific version
just simulate succ-v210
```

| Version | Tenderly Simulation |
|---------|---------------------|
| succ-v210 | _Pending — link will be added once simulation is run_ |

Historical executed-upgrade simulations (v4, v5, succ-v2, succ-v201) remain registered in `justfile` for reference.

### Verification

```bash
# Decode succ-v210 calldata (Multicall3 aggregate3)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/10-succ-v210.json)
```

succ-v210 should be verified on **Sepolia** prior to mainnet signing (see [upgrades/sepolia/04-succ-v210.json](./upgrades/sepolia/04-succ-v210.json)).

### Ledger Workaround for Celo App Users

The Celo Ledger app does not support signing EIP-712 typed data. Use the "Eth Recovery" app instead:

1. Open Ledger Live → Settings → Experimental Features → Developer Mode
2. My Ledger → Search "Eth Recovery" → Install
3. Open the Eth Recovery app on your Ledger before signing

```bash
just sign_ledger succ-v210 clabs celo 1
```

## Command Reference

<details open>
<summary><strong>sign_ledger</strong> - Sign a single version</summary>

```bash
just sign_ledger <version> <team> <ledger_app> [account_index] [grand_child]
```

| Parameter | Options | Default | Description |
|-----------|---------|---------|-------------|
| `version` | `v2`, `v3`, `v4`, `v5`, `succ-v1`, `succ-v102`, `succ-v2`, `succ-v201`, `succ-v210` | - | Upgrade version |
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

1. **Signers** → Run `just sign_ledger succ-v210 <team> <ledger_app>` and send `out.json` to the facilitator
2. **Facilitator** → Collects signatures and performs child multisig approvals (cLabs + Security Council)
3. **Child Multisigs** → Approve execution on the parent multisig
4. **Parent Multisig** → Executes the succ-v210 transaction
