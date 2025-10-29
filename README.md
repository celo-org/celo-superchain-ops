# Celo SuperchainOps

Repository created to be equivalent of Optimism SuperchainOps, but for Celo Mainnet

### Purpose

For a detailed explanation of the purpose of this tool, the smart contracts involved, and the upgrade process, please see [PURPOSE.md](./PURPOSE.md).

## Installation

You will need to install a number of software dependencies to effectively use the Celo SuperchainOps. We use Mise as a dependency manager for these tools. Once properly installed, Mise will provide the correct versions for each tool. Mise does not replace any other installations of these binaries and will only serve these binaries when you are working inside of the Celo SuperchainOps directory.

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

### Install project dependencies with Mise

Then make Mise trust current project:
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

Rename `.env.sample` to `.env` and fill in the required environment variables. You can use the `.env.sample` file as a reference. The `RPC_URL` should be set to the RPC URL of an L1 Ethereum mainnet node.

## Current Release: OpSuccinct Upgrade

This section outlines the process for signing the Celo Mainnet OpSuccinct upgrade. As a signer, you are approving the transaction that will execute this upgrade on-chain.

**Previous upgrades:** The v2 and v3 (Isthmus) upgrades have been successfully executed. This repository now supports individual upgrades on a per-release basis.

### What is the OpSuccinct Upgrade?

The OpSuccinct upgrade transitions Celo Mainnet's fault proof system to use **OP Succinct games**, enabling zero-knowledge proof-based dispute resolution. This upgrade:

1. **Switches the game type** from standard Optimism fault proofs to OP Succinct games
2. **Deploys new contracts** using deterministic CREATE3 deployment:
   - `AccessManager`: Manages permissions for the OP Succinct system
   - `OPSuccinctFaultDisputeGame`: Implements ZK-proof based dispute resolution

The deployment addresses were pre-calculated using CREATE3 (see [celo-org/op-succinct#43](https://github.com/celo-org/op-succinct/pull/43)). This approach allows parameter fine-tuning until the final deployment without changing contract addresses.

### Upgrade Workflow Status

This signing phase is part of a larger upgrade process:

- ✅ **Pre-calculate deployment addresses** using CREATE3 deterministic deployment
- ✅ **Generate upgrade calldata** locally
- ✅ **Simulate upgrade** locally, on forked network, and in Tenderly vnet
- ✅ **Prepare signing infrastructure** and test with this repository
- 🔄 **Gather signatures from multisig signers** ← **You are here**
- ⏳ **Fine-tune parameters** for official release (can be done until deployment)
- ⏳ **Deploy contracts** to pre-calculated addresses with finalized parameters
- ⏳ **Execute governance proposal** to register OP Succinct games in DisputeGameFactory
- ⏳ **Migrate to OP Succinct proposer** and switch game type in OptimismPortal2

### Summary for Signers

*   **What are you signing?** You are signing a transaction that approves the OpSuccinct upgrade calldata. This transaction will be executed by the Celo Mainnet multisig to configure the system to recognize OP Succinct games.
*   **What are the changes?** The upgrade registers OP Succinct contracts with the system. Pre-calculated deployment addresses can be found in [addresses/succinct.json](./addresses/succinct.json). The upgrade transaction details are in [upgrades/succinct.json](./upgrades/succinct.json). Tenderly simulation is available via `just simulate succinct` command.
*   **What is the expected output?** After signing with your Ledger, the process will generate an `out.json` file containing your signature, account address, transaction hash, and transaction data. This file must be sent to the facilitator (cLabs).
*   **Why use CREATE3?** CREATE3 deployment ensures addresses remain constant regardless of constructor parameters. This allows the team to optimize parameters until the final deployment without invalidating signatures.
*   **What is `mise`?** `mise` is a tool that manages the versions of software dependencies (like `go`, `forge`, etc.) used in this repository. It ensures that you are using the correct versions for all commands without interfering with your system's existing installations.

The main command you will be using is `sign_ledger`. This command will ask you to sign one transaction on your Ledger device. After successful signing, it will generate an `out.json` file. This file contains the signature and needs to be sent back to the facilitator. **Please verify the account value in this file matches the account you intended to sign with.**

The default derivation path used is the Ethereum derivation path (`m/44'/60'/<account_index>'/0/0`). If you choose the Celo ledger app, make sure you have the Eth Recovery app open on your Ledger - [see below](#ledger-workaround-for-celo-app-users)

### Decode OpSuccinct Upgrade Calldata

To understand exactly what operations the OpSuccinct upgrade performs, you can decode the calldata:

```bash
./scripts/decode_succinct_calldata.sh
```

This script will:
- Identify the top-level function call (Multicall3.aggregate3)
- Extract and decode the two nested operations:
  1. **setInitBond(gameType=42, bond=0.001 ETH)**: Configures the initial bond amount for OP Succinct games
  2. **setImplementation(gameType=42, impl=0x113f434f82FF82678AE7f69Ea122791FE1F6b73e)**: Registers the OPSuccinctFaultDisputeGame implementation
- Display the actual parameter values extracted from the calldata
- Verify the implementation address matches [addresses/succinct.json](./addresses/succinct.json)

This provides complete transparency into the operations that will be executed when the upgrade is approved.

### Verify OpSuccinct Bytecode

**Important:** The OpSuccinct contracts use CREATE3 deterministic deployment. The addresses in [addresses/succinct.json](./addresses/succinct.json) are **pre-calculated** but not yet deployed on mainnet. Bytecode verification against on-chain code will work after deployment completes.

To verify the bytecode against forge artifacts:

**1. Clone the `op-succinct` repository:**

```bash
git clone https://github.com/celo-org/op-succinct
cd op-succinct
git checkout develop
```

**2. Build the contracts:**

```bash
cd contracts
forge build
```

**3. Run the comparison script:**

From the `celo-superchain-ops` repository:

```bash
# from /path/to/celo-superchain-ops
./scripts/compare_succinct.sh /path/to/op-succinct/contracts/out
```

**Note:** The script will display a warning that contracts are not yet deployed. Before deployment, you can verify the forge artifacts match the expected contracts. After deployment, the script will verify on-chain bytecode matches the artifacts.

**Understanding CREATE3 Deployment:**

CREATE3 allows addresses to be pre-calculated independently of constructor parameters. Benefits:
- Addresses remain constant even if constructor parameters change
- Parameters can be fine-tuned until deployment without invalidating signatures
- Deployment address is deterministic and verifiable

For implementation details, see the deterministic deployment PR: [celo-org/op-succinct#43](https://github.com/celo-org/op-succinct/pull/43)

### Simulate OpSuccinct Upgrade

To simulate the OpSuccinct upgrade in Tenderly:

```bash
just simulate succinct
```

This will display two Tenderly simulation URLs:
- **Pre-deployment simulation**: Shows the contract deployment transaction
- **Upgrade simulation**: Shows the governance proposal execution registering OP Succinct games

**Note:** To properly view the simulation, you may need to enable "Dev" mode in Tenderly. This switch is located in the top-right corner of the Tenderly interface.

For detailed guidance on verifying the simulation, refer to the [Tenderly verification guide](./TENDERLY.md).


### If you are a member of the `council` team:

You will need to sign the OpSuccinct upgrade transaction for the `council` safe.

Specify the ledger app and account index to use (indices start at 0):
```bash
just sign_ledger succinct council [eth|celo] <index>

# example - using Ethereum app with account index 1
just sign_ledger succinct council eth 1
```

After signing, verify the `out.json` file contains your correct account address, then **send the JSON file to your facilitator.**

### If you are a member of the `clabs` team:

You will need to sign the OpSuccinct upgrade transaction for the `clabs` safe.

Specify the ledger app and account index to use (indices start at 0):
```bash
just sign_ledger succinct clabs [eth|celo] <index>

# example - using Ethereum app with account index 1
just sign_ledger succinct clabs eth 1
```

After signing, verify the `out.json` file contains your correct account address, then **send the JSON file to your facilitator.**

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
just sign_ledger succinct clabs celo 1
```

## Available Commands

### `sign_ledger` - Sign upgrade with ledger app and account index

This command signs the specified upgrade transaction. It will prompt for one signature on your Ledger device and output an `out.json` file with the signature.

```bash
just sign_ledger <version> <team> <ledger_app> [account_index]
```

**Parameters:**
*   `version`: The upgrade version to sign (`succinct`, `v2`, `v3`)
*   `team`: The team that is signing (`clabs`, `council`)
*   `ledger_app`: The Ledger app to use (`eth` or `celo`)
*   `account_index`: The account index to use (optional, defaults to `0`)

**Examples:**
```bash
# Sign succinct upgrade using Ethereum app with default account (index 0)
just sign_ledger succinct clabs eth

# Sign succinct upgrade using Ethereum app with account index 1
just sign_ledger succinct clabs eth 1

# Sign succinct upgrade using Celo app with workaround and account index 2
just sign_ledger succinct council celo 2
```

### `sign` - Sign upgrade with custom HD path

If you need to use a custom HD path, you can use the `sign` command directly. Note that you might need to escape special characters for your shell.

```bash
just sign <version> <team> [hd_path] [grand_child]
```

**Parameters:**
*   `version`: The upgrade version to sign (`succinct`, `v2`, `v3`)
*   `team`: The team that is signing (`clabs`, `council`)
*   `hd_path`: The hardware wallet derivation path (optional)
*   `grand_child`: Address of grand child multisig if applicable (optional)

**Examples:**
```bash
# Sign with custom Celo derivation path
just sign succinct clabs "m/44'/52752'/1'/0/0"

# Sign with custom Ethereum derivation path
just sign succinct council "m/44'/60'/1'/0/0"
```

### `simulate` - View Tenderly simulation

Display the Tenderly simulation URL for an upgrade:

```bash
just simulate <version>
```

**Example:**
```bash
just simulate succinct
```

## Derivation Paths

The `sign_ledger` command automatically generates the correct derivation paths based on the chosen ledger app:

*   **`eth`**: `m/44'/60'/<account_index>'/0/0`
*   **`celo`**: `m/44'/52752'/<account_index>'/0/0`

Where `<account_index>` defaults to `0` if not specified.

## How it works

The `sign_ledger` command is a convenience wrapper that:
1. Takes the version, team, ledger app, and account index as parameters
2. Generates the appropriate HD path based on the app choice and account index
3. Calls the `sign` command with the generated HD path

This provides both flexibility (you can use custom HD paths with `sign`) and convenience (you can use predefined app paths with `sign_ledger`).

## How it will be executed

The full execution process for the OpSuccinct upgrade:

1. **Distribution**: This signing routine is distributed to individual signers
2. **Signing**: Signers sign the transaction and forward the `out.json` file to the facilitator
3. **Child Approval**: Facilitator performs approval on child multisigs (cLabs and Security Council) using the collected signatures
4. **Parent Approval**: Both child multisigs approve the execution on the parent multisig (owner of Celo OpStack)
5. **Post-Execution Steps** (performed separately after signature collection):
   - Deploy contracts to pre-calculated CREATE3 addresses with finalized parameters
   - Execute governance proposal to register OP Succinct games in DisputeGameFactory
   - Migrate to OP Succinct proposer and switch game type in OptimismPortal

**Note**: Steps 1-4 happen during the signing and approval phase (current phase). Step 5 happens after successful signature collection and represents the actual deployment and migration.
