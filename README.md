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

## Active Release: succ-v220 (OPSuccinct v2.2.0)

A single proposal executed via the parent multisig that points game type `42` at a redeployed `OPSuccinctFaultDisputeGame` (new verification keys, new `AccessManager`) and disables game type `0`.

| Version | Description | Source |
|---------|-------------|--------|
| **succ-v220** | Set game type `42` to `OPSuccinctFaultDisputeGame` (`0x1736C1014BdcA32aBE1Bd67762bA97673701EDe7`, v2.1.0, new `AccessManager` `0x2c4e8F333224139193790fB27Fc99b926061d889`) and set game type `0` to `address(0)` on the `DisputeGameFactory` (`0xFbAC162162f4009Bb007C6DeBC36B1dAC10aF683`) | celo-org/op-succinct `celo/v2.2.0` |

**Previous upgrades (executed):** v2, v3 (Isthmus), succ-v1 (OpSuccinct v1.0.0), succ-v102 (OpSuccinct v1.0.2), v4, v5, succ-v2, succ-v201, succ-v210 (OPSuccinct v2.1.0 — Hypercube), and eigenda-cert-v3 (EigenDA Cert Verifier activation).

### What You're Signing

A single governance proposal executed via the parent multisig:

- **succ-v220**: Multicall3 batch with two calls on the `DisputeGameFactory` at [`0xFbAC162162f4009Bb007C6DeBC36B1dAC10aF683`](https://etherscan.io/address/0xFbAC162162f4009Bb007C6DeBC36B1dAC10aF683):
  1. `setImplementation(42, 0x1736C1014BdcA32aBE1Bd67762bA97673701EDe7)` — new OP Succinct game with aggregation vkey `0x006e44fd…`, range vkey commitment `0x543e17e8…` and rollup config hash `0x22734d60…`. Durations, bonds, verifier, `AnchorStateRegistry` and the proposer/challenger allowlist are unchanged. The new `AccessManager` is owned by the cLabs Safe.
  2. `setImplementation(0, 0x0000000000000000000000000000000000000000)` — stops new game type `0` games. The respected game type stays `42`.

The refund receiver for this release is `0x3bec6009e5b9611b7765BC245A4Bb420817483E2` (set in the upgrade JSON). It is part of the Safe transaction hash; gas price is `0`, so nothing is refunded.

See [addresses/mainnet/12-succ-v220.json](./addresses/mainnet/12-succ-v220.json) for the deployed contract addresses and [upgrades/mainnet/12-succ-v220.json](./upgrades/mainnet/12-succ-v220.json) for the calldata.

### Signing Process

Sign with `sign_ledger`:

```bash
just sign_ledger succ-v220 <team> <ledger_app> [account_index] [grand_child]
```

This produces `out.json` — **send it to the facilitator.**

#### Examples

```bash
# Council team, Ethereum app, default account
just sign_ledger succ-v220 council eth

# cLabs team, Ethereum app, account index 1
just sign_ledger succ-v220 clabs eth 1

# Council team with nested multisig (e.g. Mento)
just sign_ledger succ-v220 council eth 0 0xMentoMultisigAddress
```

### Tenderly Simulations

```bash
# Show all simulation links
just simulate

# Show a specific version
just simulate succ-v220
```

| Version | Tenderly Simulation |
|---------|---------------------|
| succ-v210 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/7682d855-f265-40df-abe0-b3b829eb824a/tx/0x96891cb8e0f89e77228ae0ca53ca4cf9c97c9bb162615eb11b506de1644734e4) |
| eigenda-cert-v3 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/7f58af78-e2ba-4ef2-8cd1-6dd329723aee/tx/0x2792faf8a438323dfd76844ef9f5d6b346c677fbf1951430cb458883073c6fd7) |
| succ-v220 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/06033781-b88b-4942-b821-fd5450c45439/tx/0xb5864c68c41725af58188e14a66c4624c5aa9b637c10748eab27485acc20b62b) |

Historical executed-upgrade simulations (v4, v5, succ-v2, succ-v201) remain registered in `justfile` for reference.

### Verification

```bash
# Decode succ-v220 calldata (Multicall3 aggregate3 with both setImplementation calls)
./scripts/decode_calldata.sh succ-v220

# Compare deployed bytecode with op-succinct `celo/v2.2.0` forge artifacts
./scripts/compare.sh succ-v220 <path_to_op-succinct>/contracts/out
```

The decoder should list exactly two operations: `setImplementation(gameType=42, impl=0x1736…1EDe7)` and `setImplementation(gameType=0, impl=0x0000…0000)`.

succ-v220 was executed on **Sepolia** first (tx [`0x2dbd82…540a`](https://sepolia.etherscan.io/tx/0x2dbd8242cabc248f4ca0f65f230a4ff09e25295224ec1a22459e73c1aab6540a)) with the same two calls.

### Ledger Workaround for Celo App Users

The Celo Ledger app does not support signing EIP-712 typed data. Use the "Eth Recovery" app instead:

1. Open Ledger Live → Settings → Experimental Features → Developer Mode
2. My Ledger → Search "Eth Recovery" → Install
3. Open the Eth Recovery app on your Ledger before signing

```bash
just sign_ledger succ-v220 clabs celo 1
```

## Command Reference

<details open>
<summary><strong>sign_ledger</strong> - Sign a single version</summary>

```bash
just sign_ledger <version> <team> <ledger_app> [account_index] [grand_child]
```

| Parameter | Options | Default | Description |
|-----------|---------|---------|-------------|
| `version` | `v2`, `v3`, `v4`, `v5`, `succ-v1`, `succ-v102`, `succ-v2`, `succ-v201`, `succ-v210`, `eigenda-cert-v3`, `succ-v220` | - | Upgrade version |
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

1. **Signers** → Run `just sign_ledger succ-v220 <team> <ledger_app>` and send `out.json` to the facilitator
2. **Facilitator** → Collects signatures and performs child multisig approvals (cLabs + Security Council)
3. **Child Multisigs** → Approve execution on the parent multisig
4. **Parent Multisig** → Executes the succ-v220 transaction
