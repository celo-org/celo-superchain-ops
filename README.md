# Celo SuperchainOps

Repository created to be equivalent of Optimism SuperchainOps, but for Celo Mainnet

## Installation

### Install and configure Mise

First install Mise:
```bash
./scripts/install-mise.sh
```

To ensure `mise` works correctly, you must activate it in your shell, which sets up the proper environment for your tools (like forge, just, go, etc.).

After running the installation script above, you will see the following log output:

```bash
mise: installing mise...
#################### 100.0%
mise: installed successfully to /Users/<username>/.local/bin/mise
mise: run the following to activate mise in your shell:
echo "eval \"\$(/Users/<username>/.local/bin/mise activate zsh)\"" >> "/Users/<username>/.zshrc"

mise: run `mise doctor` to verify this is setup correctly
```

You must follow the remaining instructions in the log output to fully activate mise in your shell (i.e. add the eval command to your shell profile). Please note, the log output may be different for you depending on your shell.

After adding eval command it is necessary to restart your terminal or source your shell profile (e.g. `source ~/.zshrc` for Zsh).

### Install projects deps with Mise

Than make Mise trust current project:
```bash
mise trust
```

Install project dependencies with Mise:
```bash
mise install
```

### Install other dependencies

Install EIP712 dependency with Just:
```bash
just install-eip712sign
```

### Setup environment variables

Rename `.env.sample` to `.env` and fill in the required environment variables. You can use the `.env.sample` file as a reference.

## Current release steps (v2 and v3) Isthmus

The main command you will be using is `sign_all_ledger`. This command will ask you to sign two transactions (v2 and v3) on your Ledger device. After successful signing, it will generate an `out.json` file. This file contains the signatures and needs to be sent back to cLabs. Please check the account value in this file to make sure it matches the account you intended to sign with.

The default derivation path used is the Ethereum derivation path (`m/44'/60'/0'/0/<account_index>`). If you will choose celo ledger app make sure you have the Eth Recovery app open on your Ledger - [see below](#ledger-workaround-for-celo-app-users)

### Simulation of v2 and v3 upgrade

To simulate the v2 and v3 upgrades, you can use the following commands which output tenderly link for each upgrade:

```bash
just simulate v2
```

```bash
just simulate v3
```


### If you are a member of the `council` team:

You will need to sign the transactions for the `council` safe for both `v2` and `v3`.

Specify the ledger app and account index to use, indexes start at 0: 
```bash
just sign_all_ledger council [eth|celo] <index> 

# example
just sign_all_ledger council eth 1
```

### If you are a member of the `clabs` team:

You will need to sign the transactions for the `clabs` safe for both `v2` and `v3`.

Specify the ledger app and account index to use, indexes start at 0: 
```bash
just sign_all_ledger clabs [eth|celo] <index>

# example
just sign_all_ledger clabs eth 1
```

### Ledger Workaround for Celo App Users

The Celo Ledger app does not support signing EIP-712 typed data, which is required for this process. However, there is a workaround using the "Eth Recovery" app on your Ledger.

**Steps For LedgerLive (to get eth recovery app)**
1. open ledger live
2. Settings -> Experimental Features -> Developer Mode
3. Plug In Ledger and Unlock
4. go to My Ledger menu
5. search in App Catalog for "Eth Recovery"
6. if no app found Check if ledger is prompting to upgrade firmware, if so do that and go back to step 6
7. Install Eth Recovery App

**Steps For the Actual Tx execution**
Connect as you usually would to safe with celo terminal but instead of opening the Celo App have the Eth Recovery App Open.

You can use `celo` as the ledger app parameter, but you need to have the Eth Recovery App open on your device for the signing to succeed.

```bash
just sign_all_ledger clabs celo 1
```

## Available Commands

### `sign_all_ledger` - Sign both upgrades with ledger app and account index

This command signs both v2 and v3 upgrades. It will prompt for two signatures on your Ledger device and output an `out.json` file with the signatures.

```bash
just sign_all_ledger <team> [ledger_app] [account_index]
```

**Parameters:**
*   `team`: The team that is signing (`clabs`, `council`)
*   `ledger_app`: The Ledger app to use (`eth` or `celo`). Defaults to `eth`.
*   `account_index`: The account index to use (optional, defaults to `0`)

**Examples:**
```bash
# Using Ethereum app with default account (index 0)
just sign_all_ledger clabs eth

# Using Ethereum app with account index 1
just sign_all_ledger clabs eth 1

# Using Celo app with workaround and account index 2
just sign_all_ledger council celo 2
```

### `sign_all` - Sign both upgrades with custom HD path

It is also possible to specify a very custom HD path. Note that you might need to escape special characters for your shell.

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

# Using custom Ethereum derivation path with escaped single quotes
just sign_all council "m/44\'/60\'/1\'/0/0"
```

## Derivation Paths

The `sign_all_ledger` command automatically generates the correct derivation paths based on the chosen ledger app:

*   **`eth` (default)**: `m/44'/60'/0'/0/<account_index>`
*   **`celo`**: `m/44'/52752'/0'/0/<account_index>`

Where `<account_index>` defaults to `0` if not specified.

## How it works

The `sign_all_ledger` command is a convenience wrapper that:
1. Takes the ledger app and account index as parameters
2. Generates the appropriate HD path based on the app choice
3. Calls the original `sign` command with the generated HD path

This provides both flexibility (you can use custom HD paths with `sign_all`) and convenience (you can use predefined app paths with `sign_all_ledger`).
