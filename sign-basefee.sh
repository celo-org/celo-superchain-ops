#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Sign a base fee update proposal for SystemConfig via cLabs Safe
# Must be run AFTER 05-v4, 06-v5, 07-succ-v2 are executed on mainnet
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load .env if present
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

NETWORK="${NETWORK:-mainnet}"

case $NETWORK in
"mainnet")
    CLABS_SAFE="0x9Eb44Da23433b5cAA1c87e35594D15FcEb08D34d"
    MULTISEND="0x9641d764fc13c8B624c04430C7356C1C7C8102e2"
    SYSTEM_CONFIG="0x89E31965D844a309231B1f17759Ccaf1b7c09861"
    REFUND_RECEIVER="0x95ffac468e37ddeef407ffef18f0cc9e86d8f13b"
    ;;
"sepolia")
    CLABS_SAFE="0x769b480A8036873a2a5EB01FE39278e5Ab78Bb27"
    MULTISEND="0x9641d764fc13c8B624c04430C7356C1C7C8102e2"
    SYSTEM_CONFIG="0x760a5f022c9940f4a074e0030be682f560d29818"
    RPC_URL="${SEPOLIA_RPC_URL:?Set SEPOLIA_RPC_URL in .env}"
    REFUND_RECEIVER="0x5e60d897Cd62588291656b54655e98ee73f0aabF"
    ;;
*)
    echo "Invalid network: $NETWORK" && exit 1
    ;;
esac

# --- Constants ---
VALUE=0
TX_DELEGATECALL=1
SAFE_TX_GAS=0
BASE_GAS=0
GAS_PRICE=0
GAS_TOKEN="0x0000000000000000000000000000000000000000"

# --- Parse arguments ---
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --min-base-fee <wei>     Minimum base fee in wei (default: 50000000000 = 50 gwei)"
    echo "  --da-scalar <uint16>     DA footprint gas scalar (default: 1)"
    echo "  --hd-path <path>         Ledger HD derivation path"
    echo "  --ledger-app <celo|eth>  Ledger app to use (sets HD path automatically)"
    echo "  --account-index <n>      Ledger account index (default: 0)"
    echo "  -h, --help               Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --ledger-app eth"
    echo "  $0 --ledger-app celo --min-base-fee 25000000000 --da-scalar 2"
    echo "  $0 --hd-path \"m/44'/60'/0'/0/0\" --min-base-fee 50000000000"
    echo ""
    echo "Environment variables:"
    echo "  NETWORK        mainnet (default) or sepolia"
    echo "  RPC_URL        RPC endpoint"
    echo "  TEST_PK        Private key for testing (bypasses Ledger)"
    exit 0
}

MIN_BASE_FEE_WEI=50000000000
DA_SCALAR=1
HD_PATH=""
LEDGER_APP=""
ACCOUNT_INDEX=0

while [[ $# -gt 0 ]]; do
    case $1 in
        --min-base-fee) MIN_BASE_FEE_WEI="$2"; shift 2 ;;
        --da-scalar) DA_SCALAR="$2"; shift 2 ;;
        --hd-path) HD_PATH="$2"; shift 2 ;;
        --ledger-app) LEDGER_APP="$2"; shift 2 ;;
        --account-index) ACCOUNT_INDEX="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1" && exit 1 ;;
    esac
done

# Resolve HD path from ledger app if provided
if [ -n "$LEDGER_APP" ]; then
    case $LEDGER_APP in
        celo) HD_PATH="m/44'/52752'/${ACCOUNT_INDEX}'/0/0" ;;
        eth)  HD_PATH="m/44'/60'/${ACCOUNT_INDEX}'/0/0" ;;
        *)    echo "Invalid ledger_app: $LEDGER_APP. Must be 'celo' or 'eth'." && exit 1 ;;
    esac
fi

echo ""
echo "========================================================================="
echo "  BASE FEE UPDATE - SIGNING"
echo "========================================================================="
echo ""
echo "  Network:       $NETWORK"
echo "  Safe:          $CLABS_SAFE"
echo "  SystemConfig:  $SYSTEM_CONFIG"
echo "  Min base fee:  ${MIN_BASE_FEE_WEI} wei"
echo "  DA scalar:     $DA_SCALAR"
echo ""

# Nonce 27: after 05-v4 (nonce 24), 06-v5 (25), 07-succ-v2 (26) execute
NONCE=27
echo "  cLabs Safe nonce: $NONCE (post 05/06/07 execution)"
echo ""

# --- Build MultiSend calldata ---

# Encode individual calls
CALL1=$(cast calldata "setMinBaseFee(uint64)" "$MIN_BASE_FEE_WEI")
CALL2=$(cast calldata "setDAFootprintGasScalar(uint16)" "$DA_SCALAR")

# Build MultiSend packed data
# Each entry: uint8 operation (0=call) | address to | uint256 value | uint256 dataLength | bytes data
SC_NOPFX="${SYSTEM_CONFIG#0x}"

CALL1_NOPFX="${CALL1#0x}"
CALL1_LEN=$(printf '%064x' $((${#CALL1_NOPFX} / 2)))
ENTRY1="00${SC_NOPFX}0000000000000000000000000000000000000000000000000000000000000000${CALL1_LEN}${CALL1_NOPFX}"

CALL2_NOPFX="${CALL2#0x}"
CALL2_LEN=$(printf '%064x' $((${#CALL2_NOPFX} / 2)))
ENTRY2="00${SC_NOPFX}0000000000000000000000000000000000000000000000000000000000000000${CALL2_LEN}${CALL2_NOPFX}"

PACKED="${ENTRY1}${ENTRY2}"
CALLDATA=$(cast calldata "multiSend(bytes)" "0x${PACKED}")

# --- Compute Safe tx hash and EIP-712 data ---

TX_HASH=$(cast call "$CLABS_SAFE" \
    "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
    "$MULTISEND" "$VALUE" "$CALLDATA" "$TX_DELEGATECALL" "$SAFE_TX_GAS" "$BASE_GAS" "$GAS_PRICE" "$GAS_TOKEN" "$REFUND_RECEIVER" "$NONCE" \
    -r "$RPC_URL"
)
echo "  Safe tx hash: $TX_HASH"

TX_DATA=$(cast call "$CLABS_SAFE" \
    "encodeTransactionData(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes)" \
    "$MULTISEND" "$VALUE" "$CALLDATA" "$TX_DELEGATECALL" "$SAFE_TX_GAS" "$BASE_GAS" "$GAS_PRICE" "$GAS_TOKEN" "$REFUND_RECEIVER" "$NONCE" \
    -r "$RPC_URL"
)
echo "  Safe tx data: $TX_DATA"
echo ""

# --- Sign ---

if [ -z "${TEST_PK:-}" ]; then
    if [ -z "${HD_PATH:-}" ]; then
        echo "Signing with Ledger (default derivation path)..."
        echo "$TX_DATA" | ./eip712sign -ledger > .tmp
    else
        echo "Signing with Ledger ($HD_PATH)..."
        echo "$TX_DATA" | ./eip712sign -ledger -hd-paths "$HD_PATH" > .tmp
    fi
else
    echo "Signing with test private key..."
    echo "$TX_DATA" | ./eip712sign -private-key "${TEST_PK:2}" > .tmp
fi

ACCOUNT=$(grep Signer .tmp)
ACCOUNT="${ACCOUNT#Signer: }"

SIG=$(grep Signature .tmp)
SIG="${SIG#Signature: }"

rm -f .tmp

echo "  Your account: $ACCOUNT"
echo "  Your signature: $SIG"
echo ""

# --- Write output ---

echo "{\"version\": \"basefee\", \"network\": \"${NETWORK}\", \"hash\": \"${TX_HASH}\", \"data\": \"${TX_DATA}\", \"sig\": \"${SIG}\", \"account\": \"${ACCOUNT}\"}" > out-basefee.json
echo "Saved to out-basefee.json"
cat out-basefee.json | jq
