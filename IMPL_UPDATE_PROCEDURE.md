# OPSuccinctFaultDisputeGame Implementation Address Update Procedure

This document describes the exact steps to update the succ-v2 upgrade when a new OPSuccinctFaultDisputeGame implementation is deployed to Ethereum mainnet.

> **Note:** Once succ-v2 has been executed on mainnet, subsequent impl updates are published as new standalone proposals (e.g. `succ-v201` → `upgrades/mainnet/09-succ-v201.json`) rather than edits to `07-succ-v2.json`. The new proposal is a Multicall3 batch with a single `setImplementation(42, <NEW_IMPL>)` call (no `transferOwnership`).

## Prerequisites

- New implementation address deployed on Ethereum mainnet (must have code)
- Access to both repos:
  - `celo-superchain-ops` (this repo)
  - `celo-monorepo/packages/op-tooling/exec/exec-mocked.sh`
- Tools: `cast`, `jq`, `just`, `anvil`

## Procedure

### 1. Verify new implementation exists on mainnet

```bash
NEW_IMPL=0x<NEW_ADDRESS_HERE>
cast code $NEW_IMPL -r https://eth.llamarpc.com
# Must return bytecode (not 0x)
```

### 2. Update `addresses/mainnet/07-succ-v2.json`

Replace the `OPSuccinctFaultDisputeGame` value with the new address:

```json
{
    "OPSuccinctFaultDisputeGame": "0x<NEW_ADDRESS>"
}
```

### 3. Update `upgrades/mainnet/07-succ-v2.json`

In the `calldata` hex string, find the old implementation address (zero-padded to 32 bytes) and replace it with the new one.

The old address appears as: `000000000000000000000000<OLD_40_HEX_CHARS>`
Replace with: `000000000000000000000000<NEW_40_HEX_CHARS>`

The address is inside the `setImplementation(uint32, address)` call, which has selector `14f6b1a3`. You can locate it by searching for `14f6b1a3` in the calldata — the address follows 64 chars after the selector (32 bytes for the gameType parameter).

**Important:** Only replace the address in the `setImplementation` call. Do NOT touch the `transferOwnership` call or any other part of the calldata.

### 4. Update `celo-monorepo/packages/op-tooling/exec/exec-mocked.sh`

Find the `succ-v2` version block (search for `VERSION" = "succ-v2"`). In the `TX_CALLDATA=` line, perform the exact same substitution as step 3.

### 5. Verify calldata decodes correctly

```bash
# Decode the full aggregate3 calldata
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/07-succ-v2.json)
```

Expected output should show two calls:
1. `setImplementation(42, <NEW_ADDRESS>)` on DisputeGameFactory (`0xFbAC162162f4009Bb007C6DeBC36B1dAC10aF683`)
2. `transferOwnership(0x9Eb44Da23433b5cAA1c87e35594D15FcEb08D34d)` on SystemConfig (`0x89E31965D844a309231B1f17759Ccaf1b7c09861`)

Verify the inner setImplementation call explicitly:

```bash
# Extract the inner calldata from the decoded output and decode it
cast calldata-decode "setImplementation(uint32,address)" 0x14f6b1a3<...rest from decoded output...>
```

Should return:
```
42
0x<NEW_ADDRESS>
```

### 6. Verify calldatas match between repos

```bash
diff <(jq -r '.calldata' upgrades/mainnet/07-succ-v2.json | tr '[:upper:]' '[:lower:]') \
     <(grep -A5 'VERSION" = "succ-v2"' /path/to/celo-monorepo/packages/op-tooling/exec/exec-mocked.sh | grep TX_CALLDATA | sed 's/.*TX_CALLDATA=//' | tr '[:upper:]' '[:lower:]')
```

Should produce no output (empty diff = match).

### 7. Create new Tenderly Virtual TestNet and simulate all 3 upgrades

Create a new vnet forked from Ethereum mainnet:

```bash
source .env
curl -s -X POST \
  -H "X-Access-Key: $TENDERLY_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.tenderly.co/api/v1/account/c-labs/project/project/vnets" \
  -d '{
    "slug": "celo-jovian-updated",
    "display_name": "Celo Jovian Upgrades (updated impl)",
    "fork_config": { "network_id": 1 },
    "virtual_network_config": { "chain_config": { "chain_id": 1 } },
    "sync_state_config": { "enabled": false },
    "explorer_page_config": { "enabled": true, "verification_visibility": "src" }
  }' | jq '{id: .id, rpcs: [.rpcs[]? | {name: .name, url: .url}]}'
```

Save the Admin RPC URL, then run the simulation:

```bash
RPC="<ADMIN_RPC_URL>"
PARENT_SAFE=0x4092A77bAF58fef0309452cEaCb09221e556E112
CLABS_SAFE=0x9Eb44Da23433b5cAA1c87e35594D15FcEb08D34d
COUNCIL_SAFE=0xC03172263409584f7860C25B6eB4985f0f6F4636

PARENT_SIG="0x000000000000000000000000${CLABS_SAFE:2}000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000${COUNCIL_SAFE:2}000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000"

# Fund safes
cast rpc --rpc-url $RPC tenderly_setBalance $PARENT_SAFE 0xDE0B6B3A7640000
cast rpc --rpc-url $RPC tenderly_setBalance $CLABS_SAFE 0xDE0B6B3A7640000
cast rpc --rpc-url $RPC tenderly_setBalance $COUNCIL_SAFE 0xDE0B6B3A7640000

# For each version (v4, v5, succ-v2):
# 1. Compute parent tx hash
# 2. Impersonate cLabs to approveHash
# 3. Impersonate Council to approveHash
# 4. Execute parent tx with nested safe sig
```

For each upgrade, the pattern is:

```bash
TARGET=<from upgrade json .target>
CALLDATA=<from upgrade json .calldata>
PARENT_NONCE=<from upgrade json .nonce.parent>

PARENT_TX_HASH=$(cast call $PARENT_SAFE \
  "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
  $TARGET 0 "$CALLDATA" 1 0 0 0 \
  0x0000000000000000000000000000000000000000 \
  0x95ffac468e37ddeef407ffef18f0cc9e86d8f13b \
  $PARENT_NONCE -r $RPC)

cast send --from $CLABS_SAFE --unlocked $PARENT_SAFE "approveHash(bytes32)" $PARENT_TX_HASH --gas-limit 100000 -r $RPC

cast send --from $COUNCIL_SAFE --unlocked $PARENT_SAFE "approveHash(bytes32)" $PARENT_TX_HASH --gas-limit 100000 -r $RPC

cast send --from $PARENT_SAFE --unlocked $PARENT_SAFE \
  "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)" \
  $TARGET 0 "$CALLDATA" 1 0 0 0 \
  0x0000000000000000000000000000000000000000 \
  0x95ffac468e37ddeef407ffef18f0cc9e86d8f13b \
  "$PARENT_SIG" --gas-limit 16000000 -r $RPC
```

Execute in order: v4 (nonce 26) → v5 (nonce 27) → succ-v2 (nonce 28).

### 8. Verify post-state on Tenderly

```bash
# Parent nonce should be 29
cast call $PARENT_SAFE 'nonce()(uint256)' -r $RPC

# DGF game 42 should be the NEW impl
cast call 0xFbAC162162f4009Bb007C6DeBC36B1dAC10aF683 'gameImpls(uint32)(address)' 42 -r $RPC

# SystemConfig owner should be cLabs Safe
cast call 0x89E31965D844a309231B1f17759Ccaf1b7c09861 'owner()(address)' -r $RPC
```

### 9. Record transaction hashes

From the Tenderly simulation output, record the 3 tx hashes for v4, v5, succ-v2.

Format the explorer URLs as:
```
https://dashboard.tenderly.co/c-labs/project/testnet/<VNET_ID>/tx/<TX_HASH>
```

### 10. Update Tenderly links in 3 places

**File 1: `justfile`** — Update the `get_url()` function inside `simulate`:
- `"mainnet/v4"` → new v4 URL
- `"mainnet/v5"` → new v5 URL
- `"mainnet/succ-v2"` → new succ-v2 URL

**File 2: `README.md`** — Update the Tenderly Simulations table with new links.

**File 3: `test.sh`** — Update constants:
- `SIM_URL_V4` → new v4 URL
- `SIM_URL_V5` → new v5 URL
- `SIM_URL_SUCC_V2` → new succ-v2 URL

### 11. Run tests

```bash
bats test.sh
```

All simulate tests (20-26) should pass.

### 12. E2E test on local anvil fork

```bash
# Start anvil (use paid Tenderly RPC for speed)
anvil --port 8545 \
  --fork-url https://mainnet.gateway.tenderly.co/4FIp0G17HythOHQGCUwbqR \
  --fork-chain-id 1 \
  --fork-block-number $(cast block-number finalized -r https://mainnet.gateway.tenderly.co/4FIp0G17HythOHQGCUwbqR) \
  --gas-limit 30000000
```

Mock safes, set thresholds to 1, sign with test keys, execute all 3 upgrades, verify post-state. See previous session for the full script.

### 13. Re-sign succ-v2

**Important:** Only succ-v2 signatures need to be re-collected. v4 and v5 signatures remain valid because their calldata did not change.

```bash
just sign_ledger <new-version> <team> <ledger_app> [account_index] [grand_child]
```

### 14. Notify signers

Send updated message to Security Council asking them to re-sign **only succ-v2** (or all 3 if simpler for them). Include the new Tenderly simulation links.

## Quick Reference: File Locations

| File | Repo | What to change |
|------|------|----------------|
| `addresses/mainnet/07-succ-v2.json` | celo-superchain-ops | `OPSuccinctFaultDisputeGame` address |
| `upgrades/mainnet/07-succ-v2.json` | celo-superchain-ops | `calldata` hex (setImplementation arg) |
| `exec/exec-mocked.sh` (succ-v2 block) | celo-monorepo | `TX_CALLDATA` hex |
| `justfile` (simulate recipe) | celo-superchain-ops | Tenderly URL for succ-v2 |
| `README.md` (Tenderly table) | celo-superchain-ops | Tenderly URL for succ-v2 |
| `test.sh` (SIM_URL_SUCC_V2) | celo-superchain-ops | Tenderly URL for succ-v2 |

## TL;DR for Claude

When asked to update the succ-v2 impl address:

```
Update succ-v2 impl to 0x<NEW_ADDRESS>. Follow IMPL_UPDATE_PROCEDURE.md steps 1-14.
The celo-monorepo is at /Users/pavelhornak/repo/celo-monorepo.
The paid Tenderly RPC is https://mainnet.gateway.tenderly.co/4FIp0G17HythOHQGCUwbqR.
The Tenderly account is c-labs/project, access token is in .env as TENDERLY_ACCESS_TOKEN.
```
