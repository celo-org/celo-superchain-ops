#!/bin/bash

# This script decodes the OpSuccinct v1.0.2 upgrade calldata to show the operations
# being performed in human-readable format.
#
# The calldata is a multicall to Multicall3.aggregate3() containing one operation:
# 1. DisputeGameFactory.setImplementation()
#
# Usage: ./scripts/decode_succinct-v102_calldata.sh

set -e

CALLDATA=$(cat upgrades/succinct-v102.json | jq -r .calldata)
TARGET=$(cat upgrades/succinct-v102.json | jq -r .target)

echo "=========================================="
echo "OpSuccinct v1.0.2 Upgrade Calldata Decoder"
echo "=========================================="
echo ""
echo "Target Contract: $TARGET (Multicall3)"
echo ""

# Decode the top-level function call
echo "Top-level Function Call:"
echo "------------------------"
FUNCTION_SIG=$(echo $CALLDATA | cut -c1-10)
echo "Function Selector: $FUNCTION_SIG"
cast 4byte $FUNCTION_SIG
echo ""

echo "Decoding aggregate3 parameters..."
echo "------------------------"
echo ""

# Decode the aggregate3 call to get the array
# Remove the function selector (first 10 chars = 0x + 8 hex chars)
PARAMS=${CALLDATA:10}

echo "Attempting to decode nested calldata..."
echo ""

# Search for function selectors in the calldata
echo "Searching for function selectors in calldata..."
echo ""

# Function selector for setImplementation is 0x14f6b1a3
if echo $CALLDATA | grep -q "14f6b1a3"; then
    echo "=== Set Game Implementation ==="
    echo "-------------------------------"
    echo "Found: setImplementation(uint32,address)"
    echo "Selector: 0x14f6b1a3"
    echo ""
    IMPL_POS=$(echo $CALLDATA | grep -o "14f6b1a3" | head -1)
    IMPL_START=$(echo $CALLDATA | grep -b -o "14f6b1a3" | head -1 | cut -d: -f1)
    # Extract 64 bytes after the selector
    IMPL_DATA=$(echo ${CALLDATA:IMPL_START:138})
    echo "Call data: $IMPL_DATA"
    echo ""
    # Decode the parameters
    echo "Decoding parameters:"
    cast 4byte-decode $IMPL_DATA 2>/dev/null || echo "Manual decode needed - see raw hex above"
    echo ""
fi

echo "=== Detailed Parameter Extraction ==="
echo "------------------------------------"
echo ""

# Extract game type and implementation address from setImplementation call
if echo $CALLDATA | grep -q "14f6b1a3"; then
    # Game type is the first parameter
    IMPL_GAME_TYPE_HEX=$(echo $CALLDATA | grep -o "14f6b1a3.\{64\}" | head -1 | cut -c9-72)
    IMPL_GAME_TYPE=$((16#$IMPL_GAME_TYPE_HEX))
    echo "Game Type: $IMPL_GAME_TYPE (0x$IMPL_GAME_TYPE_HEX)"

    # Implementation address is the second parameter (last 20 bytes of 32-byte word)
    IMPL_ADDR_HEX=$(echo $CALLDATA | grep -o "14f6b1a3.\{128\}" | head -1 | cut -c97-136)
    IMPL_ADDR="0x$IMPL_ADDR_HEX"
    echo "Implementation Address: $IMPL_ADDR"
    echo "  (Should match: $(cat addresses/succinct-v102.json | jq -r .OPSuccinctFaultDisputeGame))"
    echo ""
fi

echo "=== Summary ==="
echo "---------------"
echo ""
echo "The v1.0.2 upgrade performs ONE operation on DisputeGameFactory:"
echo ""
echo "setImplementation(gameType=$IMPL_GAME_TYPE, impl=$IMPL_ADDR)"
echo "  Updates the OPSuccinctFaultDisputeGame implementation to v1.0.2"
echo ""
echo "For full transparency, review the source code:"
echo "  https://github.com/celo-org/op-succinct/blob/develop/contracts/script/fp/ConfigureDeploymentSafe.s.sol"
echo ""
echo "To verify in Tenderly simulation:"
echo "  just simulate succinct-v102"
echo ""
