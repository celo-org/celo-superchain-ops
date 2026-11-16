# How to Verify What You're Signing

This guide lets you independently confirm that the EIP-712 hash your Ledger displays corresponds exactly to the transaction simulated on Tenderly.

## Prerequisites

- `cast` (Foundry) — installed via `mise install`
- `jq`
- An Ethereum mainnet RPC endpoint (set as `RPC_URL`)

## Overview

The verification chain is:

```
Tenderly simulation → extract target + calldata → compare with upgrade JSON → compute Safe tx hash on-chain → matches Ledger hash
```

## Step 1: Fetch the transaction from Tenderly

The Tenderly vnet exposes a **public RPC endpoint** (no auth needed). Pick the version you want to verify:

| Version | Tenderly TX Hash |
|---------|-----------------|
| v4 | `0x962ef321746bb075a44226bdd645b469e761fb7dbdeb42869902b6e7ebc3b7ef` |
| v5 | `0x833bca6071ad1cf1c82acbb58fccefe75e06978454431c0597819cb743363bbb` |
| succ-v2 | `0xce7dc169f6885f8ca937135a562068e3444e6c7fc299ffb7e2341372ed006dda` |
| succ-v201 | `0x0b1d4c6376df347fc937439862c65aebaa4dcb693ed785e3202f1591a4c88bcf` |
| succ-v210 | `0x96891cb8e0f89e77228ae0ca53ca4cf9c97c9bb162615eb11b506de1644734e4` |
| eigenda-cert-v3 | `0x2792faf8a438323dfd76844ef9f5d6b346c677fbf1951430cb458883073c6fd7` |
| **succ-v220** | `0xb5864c68c41725af58188e14a66c4624c5aa9b637c10748eab27485acc20b62b` |

```bash
TENDERLY_RPC="https://virtual.mainnet.rpc.tenderly.co/06033781-b88b-4942-b821-fd5450c45439"
TX_HASH="0xb5864c68c41725af58188e14a66c4624c5aa9b637c10748eab27485acc20b62b"  # succ-v220

cast tx $TX_HASH input --rpc-url $TENDERLY_RPC > tenderly_input.txt
```

> **succ-v220** was also executed on Sepolia (tx 0x2dbd82…540a). The on-chain Safe hash recompute (Steps 5-6) is verifiable against the live mainnet Safe.

## Step 2: Decode the `execTransaction` calldata

The input is a call to `Safe.execTransaction(...)`. Decode it:

```bash
cast calldata-decode \
  "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)" \
  $(cat tenderly_input.txt) > tenderly_decoded.txt
cat -n tenderly_decoded.txt
```

The output has 10 lines, one per parameter. Lines 1-9 all go into the Safe transaction hash you sign, so a change in any of them gives a different hash. Expected values for succ-v220:

| Line | Field | Expected |
|------|-------|----------|
| 1 | `to` | `0xcA11bde05977b3631167028862bE2a173976CA11` (Multicall3) |
| 2 | `value` | `0` |
| 3 | `data` | upgrade calldata from the JSON (decoded in Step 4) |
| 4 | `operation` | `1` (DELEGATECALL) |
| 5 | `safeTxGas` | `0` |
| 6 | `baseGas` | `0` |
| 7 | `gasPrice` | `0` |
| 8 | `gasToken` | `0x0000000000000000000000000000000000000000` |
| 9 | `refundReceiver` | `0x3bec6009e5b9611b7765BC245A4Bb420817483E2` |
| 10 | `signatures` | simulation only; not part of the hash |

The refund receiver is new for succ-v220 (earlier mainnet releases used `0x95ffac468e37ddeef407ffef18f0cc9e86d8f13b`). It is set in the upgrade JSON as `refundReceiver`. With `gasPrice` = `0` nothing is ever paid to it; it only changes the hash.

Check lines 1-9 against the upgrade JSON in one go:

```bash
U=upgrades/mainnet/12-succ-v220.json
diff -i <(printf '%s\n' "$(jq -r .target $U)" 0 "$(jq -r .calldata $U)" 1 0 0 0 \
    0x0000000000000000000000000000000000000000 "$(jq -r .refundReceiver $U)") \
  <(head -9 tenderly_decoded.txt) && echo "Lines 1-9 match $U"
```

## Step 3: Compare with the upgrade JSON

```bash
# For v4:
jq -r '.target' upgrades/mainnet/05-v4.json
jq -r '.calldata' upgrades/mainnet/05-v4.json

# For v5:
jq -r '.target' upgrades/mainnet/06-v5.json
jq -r '.calldata' upgrades/mainnet/06-v5.json

# For succ-v2:
jq -r '.target' upgrades/mainnet/07-succ-v2.json
jq -r '.calldata' upgrades/mainnet/07-succ-v2.json

# For succ-v220:
jq -r '.target' upgrades/mainnet/12-succ-v220.json
jq -r '.calldata' upgrades/mainnet/12-succ-v220.json
```

**Both `target` and `calldata` must match exactly** (case-insensitive). This confirms: what Tenderly simulated = what's in the upgrade JSON.

## Step 4: Verify the upgrade calldata does what it claims

Decode the inner calldata to see the actual operations:

```bash
# v4 / v5 (OPCM upgrade)
cast calldata-decode "upgrade((address,address,bytes32)[],bool)" \
  $(jq -r '.calldata' upgrades/mainnet/05-v4.json)

# succ-v2 (Multicall3 batch)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/07-succ-v2.json)

# succ-v201 (Multicall3 batch — single setImplementation)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/09-succ-v201.json)

# succ-v210 (Multicall3 batch — single setImplementation, adds Hypercube)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/10-succ-v210.json)

# eigenda-cert-v3 (Multicall3 batch — single addCertVerifier)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/11-eigenda-cert-v3.json)
# then decode the inner call bytes → (25624000, 0xd9C4dA492c60e92e2B53abB5Bea7Aa4b8aA5b181)
cast calldata-decode "addCertVerifier(uint32,address)" <inner-bytes>

# succ-v220 (Multicall3 batch — two setImplementation calls on the DisputeGameFactory)
cast calldata-decode "aggregate3((address,bool,bytes)[])" \
  $(jq -r '.calldata' upgrades/mainnet/12-succ-v220.json)
# then decode each inner call:
#   → (42, 0x1736C1014BdcA32aBE1Bd67762bA97673701EDe7)  new OPSuccinctFaultDisputeGame
#   → (0, 0x0000000000000000000000000000000000000000)   disables new game type 0 games
cast calldata-decode "setImplementation(uint32,address)" <inner-bytes>
# or decode everything at once:
./scripts/decode_calldata.sh succ-v220
```

## Step 5: Compute the hash you'll sign — from the same inputs

The signing tool calls `Safe.getTransactionHash()` **on the live mainnet Safe contract**. You can reproduce this yourself. succ-v220 sets its own refund receiver in the upgrade JSON (`0x3bec6009e5b9611b7765BC245A4Bb420817483E2`); it is part of every hash below.

**For council signers:**

```bash
# 1. Compute parent Safe tx hash
PARENT_SAFE="0x4092A77bAF58fef0309452cEaCb09221e556E112"
TARGET=$(jq -r '.target' upgrades/mainnet/12-succ-v220.json)
CALLDATA=$(jq -r '.calldata' upgrades/mainnet/12-succ-v220.json)
PARENT_NONCE=$(jq -r '.nonce.parent' upgrades/mainnet/12-succ-v220.json)  # = 32
REFUND_RECEIVER=$(jq -r '.refundReceiver' upgrades/mainnet/12-succ-v220.json)  # = 0x3bec6009e5b9611b7765BC245A4Bb420817483E2

PARENT_TX_HASH=$(cast call $PARENT_SAFE \
    "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
    $TARGET 0 "$CALLDATA" 1 0 0 0 \
    0x0000000000000000000000000000000000000000 \
    $REFUND_RECEIVER \
    $PARENT_NONCE \
    -r $RPC_URL)

echo "Parent tx hash: $PARENT_TX_HASH"

# 2. Compute council child Safe EIP-712 data (what the Ledger will show)
COUNCIL_SAFE="0xC03172263409584f7860C25B6eB4985f0f6F4636"
COUNCIL_NONCE=$(jq -r '.nonce.council' upgrades/mainnet/12-succ-v220.json)  # = 32
CHILD_CALLDATA=$(cast calldata 'approveHash(bytes32)' $PARENT_TX_HASH)

CHILD_TX_DATA=$(cast call $COUNCIL_SAFE \
    "encodeTransactionData(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes)" \
    $PARENT_SAFE 0 "$CHILD_CALLDATA" 0 0 0 0 \
    0x0000000000000000000000000000000000000000 \
    $REFUND_RECEIVER \
    $COUNCIL_NONCE \
    -r $RPC_URL)

# Extract domain hash and message hash from the EIP-712 data
# Format: 0x1901 <domain_hash:32bytes> <message_hash:32bytes>
DOMAIN_HASH="0x${CHILD_TX_DATA:6:64}"
MESSAGE_HASH="0x${CHILD_TX_DATA:70:64}"

echo "Domain hash:  $DOMAIN_HASH"
echo "Message hash: $MESSAGE_HASH"
# → Compare these with what your Ledger displays
```

**For cLabs signers:**

```bash
# 1. Compute parent Safe tx hash
PARENT_SAFE="0x4092A77bAF58fef0309452cEaCb09221e556E112"
TARGET=$(jq -r '.target' upgrades/mainnet/12-succ-v220.json)
CALLDATA=$(jq -r '.calldata' upgrades/mainnet/12-succ-v220.json)
PARENT_NONCE=$(jq -r '.nonce.parent' upgrades/mainnet/12-succ-v220.json)  # = 32
REFUND_RECEIVER=$(jq -r '.refundReceiver' upgrades/mainnet/12-succ-v220.json)  # = 0x3bec6009e5b9611b7765BC245A4Bb420817483E2

PARENT_TX_HASH=$(cast call $PARENT_SAFE \
    "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
    $TARGET 0 "$CALLDATA" 1 0 0 0 \
    0x0000000000000000000000000000000000000000 \
    $REFUND_RECEIVER \
    $PARENT_NONCE \
    -r $RPC_URL)

echo "Parent tx hash: $PARENT_TX_HASH"

# 2. Compute cLabs child Safe EIP-712 data (what the Ledger will show)
CLABS_SAFE="0x9Eb44Da23433b5cAA1c87e35594D15FcEb08D34d"
CLABS_NONCE=$(jq -r '.nonce.clabs' upgrades/mainnet/12-succ-v220.json)  # = 34
CHILD_CALLDATA=$(cast calldata 'approveHash(bytes32)' $PARENT_TX_HASH)

CHILD_TX_DATA=$(cast call $CLABS_SAFE \
    "encodeTransactionData(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes)" \
    $PARENT_SAFE 0 "$CHILD_CALLDATA" 0 0 0 0 \
    0x0000000000000000000000000000000000000000 \
    $REFUND_RECEIVER \
    $CLABS_NONCE \
    -r $RPC_URL)

# Extract domain hash and message hash from the EIP-712 data
# Format: 0x1901 <domain_hash:32bytes> <message_hash:32bytes>
DOMAIN_HASH="0x${CHILD_TX_DATA:6:64}"
MESSAGE_HASH="0x${CHILD_TX_DATA:70:64}"

echo "Domain hash:  $DOMAIN_HASH"
echo "Message hash: $MESSAGE_HASH"
# → Compare these with what your Ledger displays
```

## Step 6: Sign and confirm on Ledger

```bash
# Council signers:
just sign_ledger succ-v220 council eth

# cLabs signers:
just sign_ledger succ-v220 clabs eth
```

Your Ledger will show two screens for each transaction:

1. **Domain hash (1/2 + 2/2)** — the EIP-712 domain separator of your child Safe
2. **Message hash (1/2 + 2/2)** — the EIP-712 struct hash of the Safe transaction

Compare both values with the output from Step 5. They must match exactly.

The full EIP-712 data is: `0x1901` + `<domain_hash>` + `<message_hash>`. The `keccak256` of this data equals the child tx hash printed by the signing tool.

## Summary

| Step | What you verified |
|------|-------------------|
| 1-3 | Tenderly simulated the exact `target` + `calldata` from the upgrade JSON |
| 4 | The calldata does what it claims (correct function calls and parameters) |
| 5 | The domain hash and message hash your Ledger shows are derived from that same `target` + `calldata` via the on-chain Safe contract |
| 6 | Your Ledger displays the expected domain hash and message hash |
