# Celo SuperchainOps

Repository created to be equivalent of Optimism SuperchainOps, but for Celo Mainnet

## Current Release Process

The release process involves two teams: `clabs` and `council`. Each team needs to sign transactions for both `v2` and `v3` to approve the new release.

### If you are a member of the `clabs` team:

You will need to sign the transactions for the `clabs` safe for both `v2` and `v3`.

Sign for `v2` and `v3`:
```bash
just sign_all_ledger clabs celo
```

If you need to use a different account index:
```bash
just sign_all_ledger clabs celo <index>
```

### If you are a member of the `council` team:

You will need to sign the transactions for the `council` safe for both `v2` and `v3`.

Sign for `v2` and `v3`:
```bash
just sign_all_ledger council celo
```

If you need to use a different account index:
```bash
just sign_all_ledger council celo <index>
```

## Available Commands

### `sign_all` - Sign both upgrades with custom HD path

```bash
just sign_all <team> <hd_path>
```

**Parameters:**
*   `team`: The team that is signing (`clabs`, `council`)
*   `hd_path`: The hardware wallet derivation path (string)

**Examples:**
```bash
# Using custom Celo derivation path
just sign_all clabs "m/44'/52752'/0'/0/1"

# Using custom Ethereum derivation path
just sign_all council "m/44'/60'/0'/0/3"
```

### `sign_all_ledger` - Sign both upgrades with ledger app and account index

```bash
just sign_all_ledger <team> <ledger_app> [account_index]
```

**Parameters:**
*   `team`: The team that is signing (`clabs`, `council`)
*   `ledger_app`: The Ledger app to use (`celo`, `eth`)
*   `account_index`: The account index to use (optional, defaults to `0`)

**Examples:**
```bash
# Using Celo app with default account (index 0)
just sign_all_ledger clabs celo

# Using Celo app with account index 1
just sign_all_ledger clabs celo 1

# Using Ethereum app with default account (index 0)
just sign_all_ledger council eth

# Using Ethereum app with account index 2
just sign_all_ledger council eth 2
```

## Derivation Paths

The `sign_all_ledger` command automatically generates the correct derivation paths:

*   **Celo app**: `m/44'/52752'/0'/0/<account_index>`
*   **Ethereum app**: `m/44'/60'/0'/0/<account_index>`

Where `<account_index>` defaults to `0` if not specified.

## How it works

The `sign_all_ledger` command is a convenience wrapper that:
1. Takes the ledger app and account index as parameters
2. Generates the appropriate HD path based on the app choice
3. Calls the original `sign` command with the generated HD path

This provides both flexibility (you can use custom HD paths with `sign_all`) and convenience (you can use predefined app paths with `sign_all_ledger`).
