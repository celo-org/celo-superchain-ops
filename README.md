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

## Active Release: eigenda-cert-v3 (EigenDA Cert Verifier activation)

A single proposal that registers a new EigenDA cert verifier on the `EigenDACertVerifierRouter`, scheduled to activate at Ethereum L1 block `25624000`. The router is owned by the parent Security Council Safe.

| Version | Description | Source |
|---------|-------------|--------|
| **eigenda-cert-v3** | Register new `EigenDACertVerifier` (`0xd9C4dA492c60e92e2B53abB5Bea7Aa4b8aA5b181`) on `EigenDACertVerifierRouter` (`0x2ea418AE1852bfC79e18B37E55F278F9c598AA08`) with activation block `25624000` | Layr-Labs/eigenda |

**Previous upgrades (executed):** v2, v3 (Isthmus), succ-v1 (OpSuccinct v1.0.0), succ-v102 (OpSuccinct v1.0.2), v4, v5, succ-v2, succ-v201, and succ-v210 (OPSuccinct v2.1.0 — Hypercube).

### What You're Signing

A single governance proposal executed via the parent multisig:

- **eigenda-cert-v3**: Multicall3 batch that calls `addCertVerifier(25624000, 0xd9C4dA492c60e92e2B53abB5Bea7Aa4b8aA5b181)` on the `EigenDACertVerifierRouter` at [`0x2ea418AE1852bfC79e18B37E55F278F9c598AA08`](https://etherscan.io/address/0x2ea418AE1852bfC79e18B37E55F278F9c598AA08) — registering the new cert verifier to activate at L1 block `25624000`.

See [addresses/mainnet/11-eigenda-cert-v3.json](./addresses/mainnet/11-eigenda-cert-v3.json) for the deployed contract addresses and [upgrades/mainnet/11-eigenda-cert-v3.json](./upgrades/mainnet/11-eigenda-cert-v3.json) for the calldata.

### Signing Process

Sign with `sign_ledger`:

```bash
just sign_ledger eigenda-cert-v3 <team> <ledger_app> [account_index] [grand_child]
```

This produces `out.json` — **send it to the facilitator.**

#### Examples

```bash
# Council team, Ethereum app, default account
just sign_ledger eigenda-cert-v3 council eth

# cLabs team, Ethereum app, account index 1
just sign_ledger eigenda-cert-v3 clabs eth 1

# Council team with nested multisig (e.g. Mento)
just sign_ledger eigenda-cert-v3 council eth 0 0xMentoMultisigAddress
```

### Tenderly Simulations

```bash
# Show all simulation links
just simulate

# Show a specific version
just simulate eigenda-cert-v3
```

| Version | Tenderly Simulation |
|---------|---------------------|
| succ-v210 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/7682d855-f265-40df-abe0-b3b829eb824a/tx/0x96891cb8e0f89e77228ae0ca53ca4cf9c97c9bb162615eb11b506de1644734e4) |
| eigenda-cert-v3 | [View on Tenderly](https://dashboard.tenderly.co/explorer/vnet/7f58af78-e2ba-4ef2-8cd1-6dd329723aee/tx/0x2792faf8a438323dfd76844ef9f5d6b346c677fbf1951430cb458883073c6fd7) |

Historical executed-upgrade simulations (v4, v5, succ-v2, succ-v201) remain registered in `justfile` for reference.

### Verification

```bash
# Decode eigenda-cert-v3 calldata (Multicall3 aggregate3)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/11-eigenda-cert-v3.json)

# Decode the inner router call
cast calldata-decode "addCertVerifier(uint32,address)" <inner-bytes-from-aggregate3>
```

The inner call should decode to `(25624000, 0xd9C4dA492c60e92e2B53abB5Bea7Aa4b8aA5b181)`.

eigenda-cert-v3 was verified on **Sepolia** (tx [`0x4b87a3…16a6`](https://sepolia.etherscan.io/tx/0x4b87a3680430af092c060c2b7f7ea96c058c9d7e79c95ea26fe6cc85d38116a6)) prior to mainnet signing.

### Ledger Workaround for Celo App Users

The Celo Ledger app does not support signing EIP-712 typed data. Use the "Eth Recovery" app instead:

1. Open Ledger Live → Settings → Experimental Features → Developer Mode
2. My Ledger → Search "Eth Recovery" → Install
3. Open the Eth Recovery app on your Ledger before signing

```bash
just sign_ledger eigenda-cert-v3 clabs celo 1
```

## Command Reference

<details open>
<summary><strong>sign_ledger</strong> - Sign a single version</summary>

```bash
just sign_ledger <version> <team> <ledger_app> [account_index] [grand_child]
```

| Parameter | Options | Default | Description |
|-----------|---------|---------|-------------|
| `version` | `v2`, `v3`, `v4`, `v5`, `succ-v1`, `succ-v102`, `succ-v2`, `succ-v201`, `succ-v210`, `eigenda-cert-v3` | - | Upgrade version |
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

1. **Signers** → Run `just sign_ledger eigenda-cert-v3 <team> <ledger_app>` and send `out.json` to the facilitator
2. **Facilitator** → Collects signatures and performs child multisig approvals (cLabs + Security Council)
3. **Child Multisigs** → Approve execution on the parent multisig
4. **Parent Multisig** → Executes the eigenda-cert-v3 transaction
