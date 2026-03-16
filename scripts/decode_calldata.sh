#!/bin/bash

# Usage: ./scripts/decode_calldata.sh <version>

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

VERSION=$1
NETWORK=${NETWORK:-mainnet}
UPGRADE_FILE=$(ls upgrades/${NETWORK}/[0-9][0-9]-${VERSION}.json 2>/dev/null)

if [ -z "$UPGRADE_FILE" ]; then
    echo "Error: No upgrade file found for $VERSION on $NETWORK"
    exit 1
fi

CALLDATA=$(jq -r .calldata "$UPGRADE_FILE")
TARGET=$(jq -r .target "$UPGRADE_FILE")

echo "=========================================="
echo "$VERSION Upgrade Calldata Decoder"
echo "=========================================="
echo ""
echo "Network: $NETWORK"
echo "Target Contract: $TARGET"
echo ""

if [ "$CALLDATA" = "TODO" ]; then
    echo "Calldata not yet populated. Fill in $UPGRADE_FILE first."
    exit 1
fi

echo "Top-level Function Call:"
echo "------------------------"
FUNCTION_SIG=$(echo $CALLDATA | cut -c1-10)
echo "Function Selector: $FUNCTION_SIG"
cast 4byte $FUNCTION_SIG
echo ""

FOUND_KNOWN_SELECTOR=false

if echo $CALLDATA | grep -q "1e334240"; then
    FOUND_KNOWN_SELECTOR=true
    echo "=== Configure Init Bond ==="
    echo "---------------------------"
    echo "Found: setInitBond(uint32,uint256)"
    echo "Selector: 0x1e334240"
    echo ""

    INIT_BOND_START=$(echo $CALLDATA | grep -b -o "1e334240" | head -1 | cut -d: -f1)
    INIT_BOND_DATA=$(echo ${CALLDATA:INIT_BOND_START:138})
    echo "Call data: $INIT_BOND_DATA"
    echo ""
    echo "Decoding parameters:"
    cast 4byte-decode $INIT_BOND_DATA 2>/dev/null || echo "Manual decode needed - see raw hex above"
    echo ""

    GAME_TYPE_HEX=$(echo $CALLDATA | grep -o "1e334240.\{64\}" | head -1 | cut -c9-72)
    GAME_TYPE=$((16#$GAME_TYPE_HEX))
    BOND_HEX=$(echo $CALLDATA | grep -o "1e334240.\{128\}" | head -1 | cut -c73-136)
    BOND_WEI=$((16#$BOND_HEX))
    BOND_ETH=$(echo "scale=6; $BOND_WEI / 1000000000000000000" | bc)

    echo "Game Type: $GAME_TYPE (0x$GAME_TYPE_HEX)"
    echo "Initial Bond: $BOND_WEI wei ($BOND_ETH ETH)"
    echo ""
fi

if echo $CALLDATA | grep -q "14f6b1a3"; then
    FOUND_KNOWN_SELECTOR=true
    echo "=== Set Game Implementation ==="
    echo "-------------------------------"
    echo "Found: setImplementation(uint32,address)"
    echo "Selector: 0x14f6b1a3"
    echo ""

    IMPL_START=$(echo $CALLDATA | grep -b -o "14f6b1a3" | head -1 | cut -d: -f1)
    IMPL_DATA=$(echo ${CALLDATA:IMPL_START:138})
    echo "Call data: $IMPL_DATA"
    echo ""
    echo "Decoding parameters:"
    cast 4byte-decode $IMPL_DATA 2>/dev/null || echo "Manual decode needed - see raw hex above"
    echo ""

    IMPL_GAME_TYPE_HEX=$(echo $CALLDATA | grep -o "14f6b1a3.\{64\}" | head -1 | cut -c9-72)
    IMPL_GAME_TYPE=$((16#$IMPL_GAME_TYPE_HEX))
    IMPL_ADDR_HEX=$(echo $CALLDATA | grep -o "14f6b1a3.\{128\}" | head -1 | cut -c97-136)
    IMPL_ADDR="0x$IMPL_ADDR_HEX"

    echo "Game Type: $IMPL_GAME_TYPE (0x$IMPL_GAME_TYPE_HEX)"
    echo "Implementation Address: $IMPL_ADDR"

    ADDRESSES_FILE=$(ls addresses/${NETWORK}/[0-9][0-9]-${VERSION}.json 2>/dev/null)
    if [ -n "$ADDRESSES_FILE" ]; then
        EXPECTED=$(jq -r '.OPSuccinctFaultDisputeGame // empty' "$ADDRESSES_FILE")
        if [ -n "$EXPECTED" ]; then
            echo "  (Should match: $EXPECTED)"
        fi
    fi
    echo ""
fi

if [ "$FOUND_KNOWN_SELECTOR" = false ]; then
    echo "Decoding full calldata..."
    echo "------------------------"
    cast 4byte-decode $CALLDATA 2>/dev/null || echo "Manual decode needed - raw calldata: $CALLDATA"
    echo ""
fi

echo "=== Summary ==="
echo "---------------"
echo ""

if [ -n "${GAME_TYPE:-}" ] && [ -n "${IMPL_GAME_TYPE:-}" ]; then
    echo "The upgrade performs TWO operations on DisputeGameFactory:"
    echo ""
    echo "1. setInitBond(gameType=$GAME_TYPE, bond=$BOND_ETH ETH)"
    echo "2. setImplementation(gameType=$IMPL_GAME_TYPE, impl=$IMPL_ADDR)"
elif [ -n "${IMPL_GAME_TYPE:-}" ]; then
    echo "The upgrade performs ONE operation on DisputeGameFactory:"
    echo ""
    echo "setImplementation(gameType=$IMPL_GAME_TYPE, impl=$IMPL_ADDR)"
else
    echo "Target: $TARGET"
    echo "Calldata: $CALLDATA"
fi

echo ""
echo "To verify in Tenderly simulation:"
echo "  just simulate $VERSION"
echo ""
