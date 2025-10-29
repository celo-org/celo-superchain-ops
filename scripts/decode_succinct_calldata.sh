#!/bin/bash

# This script decodes the OpSuccinct upgrade calldata to show the operations
# being performed in human-readable format.
#
# The calldata is a multicall to Multicall3.aggregate3() containing two operations:
# 1. DisputeGameFactory.setInitBond()
# 2. DisputeGameFactory.setImplementation()
#
# Usage: ./scripts/decode_succinct_calldata.sh

set -e

CALLDATA=$(cat upgrades/succinct.json | jq -r .calldata)
TARGET=$(cat upgrades/succinct.json | jq -r .target)

echo "=========================================="
echo "OpSuccinct Upgrade Calldata Decoder"
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

# Try to extract the calls manually by parsing the hex
# The structure is: aggregate3((address,bool,bytes)[])
# After the function selector, we have:
# - offset to array (32 bytes)
# - array length (32 bytes)
# - array elements

# Let's use cast to try to decode
echo "=== Call 1: Configure Init Bond ==="
echo "-----------------------------------"
# Extract first call data - this requires manual parsing of the hex structure
# For now, let's identify the function selectors in the calldata

# Search for function selectors in the calldata
echo "Searching for function selectors in calldata..."
echo ""

# Function selector for setInitBond is 0x1e334240
if echo $CALLDATA | grep -q "1e334240"; then
    echo "Found: setInitBond(uint32,uint256)"
    echo "Selector: 0x1e334240"
    echo ""
    # Extract the parameters following this selector
    INIT_BOND_POS=$(echo $CALLDATA | grep -o "1e334240" | head -1)
    INIT_BOND_START=$(echo $CALLDATA | grep -b -o "1e334240" | head -1 | cut -d: -f1)
    # Extract 64 bytes after the selector (two uint256 parameters)
    INIT_BOND_DATA=$(echo ${CALLDATA:INIT_BOND_START:138})
    echo "Call data: $INIT_BOND_DATA"
    echo ""
    # Decode the parameters
    echo "Decoding parameters:"
    cast 4byte-decode $INIT_BOND_DATA 2>/dev/null || echo "Manual decode needed - see raw hex above"
    echo ""
fi

echo "=== Call 2: Set Game Implementation ==="
echo "---------------------------------------"

# Function selector for setImplementation is 0x14f6b1a3
if echo $CALLDATA | grep -q "14f6b1a3"; then
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

# Extract game type and bond amount from setInitBond call
if echo $CALLDATA | grep -q "1e334240"; then
    # Game type is the first parameter (32 bytes after selector)
    GAME_TYPE_HEX=$(echo $CALLDATA | grep -o "1e334240.\{64\}" | head -1 | cut -c9-72)
    GAME_TYPE=$((16#$GAME_TYPE_HEX))
    echo "Game Type: $GAME_TYPE (0x$GAME_TYPE_HEX)"
    
    # Bond amount is the second parameter (next 32 bytes)
    BOND_HEX=$(echo $CALLDATA | grep -o "1e334240.\{128\}" | head -1 | cut -c73-136)
    BOND_WEI=$((16#$BOND_HEX))
    BOND_ETH=$(echo "scale=6; $BOND_WEI / 1000000000000000000" | bc)
    echo "Initial Bond: $BOND_WEI wei ($BOND_ETH ETH)"
    echo ""
fi

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
    echo "  (Should match: $(cat addresses/succinct.json | jq -r .OPSuccinctFaultDisputeGame))"
    echo ""
fi

echo "=== Summary ==="
echo "---------------"
echo ""
echo "The upgrade performs TWO operations on DisputeGameFactory:"
echo ""
echo "1. setInitBond(gameType=$GAME_TYPE, bond=$BOND_ETH ETH)"
echo "   Sets the initial bond amount for OP Succinct games"
echo ""
echo "2. setImplementation(gameType=$IMPL_GAME_TYPE, impl=$IMPL_ADDR)"
echo "   Registers the OPSuccinctFaultDisputeGame implementation"
echo ""
echo "For full transparency, review the source code:"
echo "  https://github.com/celo-org/op-succinct/blob/develop/contracts/script/fp/ConfigureDeploymentSafe.s.sol"
echo ""
echo "To verify in Tenderly simulation:"
echo "  just simulate succinct"
echo ""
