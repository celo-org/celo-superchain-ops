#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Execute v4, v5, succ-v2 upgrades on local Anvil fork
# Uses real signatures from ./Signatures directory
# Lowers Safe thresholds to match available signature count
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --- Constants ---
RPC_URL="${RPC_URL:-https://mainnet.gateway.tenderly.co/4FIp0G17HythOHQGCUwbqR}"
ANVIL_PORT=8545
ANVIL_RPC="http://127.0.0.1:${ANVIL_PORT}"
FORK_BLOCK="${FORK_BLOCK:-}"

PARENT_SAFE="0x4092A77bAF58fef0309452cEaCb09221e556E112"
CLABS_SAFE="0x9Eb44Da23433b5cAA1c87e35594D15FcEb08D34d"
COUNCIL_SAFE="0xC03172263409584f7860C25B6eB4985f0f6F4636"
GRAND_CHILD_SAFE="0xD1C635987B6Aa287361d08C6461491Fa9df087f2"

VALUE=0
TX_CALL=0
TX_DELEGATECALL=1
SAFE_TX_GAS=0
BASE_GAS=0
GAS_PRICE=0
GAS_TOKEN="0x0000000000000000000000000000000000000000"
REFUND_RECEIVER="0x95ffac468e37ddeef407ffef18f0cc9e86d8f13b"

# Default Anvil funded account (used as tx sender - anyone can call execTransaction)
SENDER_PK="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"

# Threshold storage slot in Gnosis Safe
THRESHOLD_SLOT="0x0000000000000000000000000000000000000000000000000000000000000004"

# --- Signature files (ALL signers) ---
CLABS_SIGNERS=(
    "Signatures/cLabs/Javi"
    "Signatures/cLabs/Karl"
    "Signatures/cLabs/Paul"
    "Signatures/cLabs/Pavel"
)
COUNCIL_SIGNERS=(
    "Signatures/Council/Aaron"
    "Signatures/Council/Kris"
    "Signatures/Council/Luca"
    "Signatures/Council/Nam"
    "Signatures/Council/Silas"
)

# --- Helper functions ---
log() { echo -e "\033[1;36m>>> $1\033[0m"; }
success() { echo -e "\033[1;32m✓ $1\033[0m"; }
error() { echo -e "\033[1;31m✗ $1\033[0m"; exit 1; }
warn() { echo -e "\033[1;33m⚠ $1\033[0m"; }

cleanup() {
    if [ -n "${ANVIL_PID:-}" ]; then
        log "Stopping Anvil (PID: $ANVIL_PID)..."
        kill "$ANVIL_PID" 2>/dev/null || true
        wait "$ANVIL_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

echo ""
echo "========================================================================="
echo "  CELO L1 UPGRADE FORK EXECUTION"
echo "  Versions: v4, v5, succ-v2"
echo "========================================================================="
echo ""

# =============================================================================
# STEP 1: Start Anvil fork
# =============================================================================
log "STEP 1: Starting Anvil fork of mainnet..."

# Kill any existing anvil on our port
lsof -ti:${ANVIL_PORT} 2>/dev/null | xargs kill 2>/dev/null || true
sleep 1

ANVIL_ARGS=(--fork-url "$RPC_URL" --port "$ANVIL_PORT" --gas-limit 30000000)
if [ -n "$FORK_BLOCK" ]; then
    ANVIL_ARGS+=(--fork-block-number "$FORK_BLOCK")
    log "  Pinning to block $FORK_BLOCK"
fi

anvil "${ANVIL_ARGS[@]}" &>/dev/null &
ANVIL_PID=$!

# Wait for Anvil to be ready
for i in {1..20}; do
    if cast block-number --rpc-url "$ANVIL_RPC" &>/dev/null; then
        break
    fi
    sleep 1
done

if ! cast block-number --rpc-url "$ANVIL_RPC" &>/dev/null; then
    error "Anvil failed to start after 20 seconds"
fi

BLOCK=$(cast block-number --rpc-url "$ANVIL_RPC")
success "Anvil forked at block $BLOCK (PID: $ANVIL_PID)"

# All subsequent RPC calls use ANVIL_RPC
R="$ANVIL_RPC"

# =============================================================================
# STEP 2: Validate signatures
# =============================================================================
echo ""
log "STEP 2: Validating signatures..."

validate_signer_is_owner() {
    local signer_addr="$1"
    local safe_addr="$2"
    local safe_name="$3"

    local owners
    owners=$(cast call "$safe_addr" "getOwners()(address[])" --rpc-url "$R")

    local signer_lower
    signer_lower=$(echo "$signer_addr" | tr '[:upper:]' '[:lower:]')
    local owners_lower
    owners_lower=$(echo "$owners" | tr '[:upper:]' '[:lower:]')

    if echo "$owners_lower" | grep -q "$signer_lower"; then
        success "  $signer_addr is owner of $safe_name"
    else
        error "  $signer_addr is NOT owner of $safe_name. Owners: $owners"
    fi
}

echo ""
echo "--- cLabs Signers ---"
for version in v4 v5 succ-v2; do
    echo "  Version: $version"
    CLABS_HASHES=()
    for signer_dir in "${CLABS_SIGNERS[@]}"; do
        sig_file=$(find "$signer_dir" -name "out-${version}*" -type f 2>/dev/null | head -1)
        if [ -z "$sig_file" ]; then
            error "No signature file for $version in $signer_dir"
        fi
        account=$(jq -r '.account' "$sig_file")
        hash=$(jq -r '.hash' "$sig_file")
        sig_version=$(jq -r '.version' "$sig_file")
        CLABS_HASHES+=("$hash")

        if [ "$sig_version" != "$version" ]; then
            error "Version mismatch in $sig_file: expected $version, got $sig_version"
        fi
        success "  $sig_file: account=$account, hash=$hash"
    done

    # Verify ALL hashes match each other
    for i in "${!CLABS_HASHES[@]}"; do
        if [ "${CLABS_HASHES[$i]}" != "${CLABS_HASHES[0]}" ]; then
            error "cLabs signature hashes don't match for $version: ${CLABS_HASHES[0]} vs ${CLABS_HASHES[$i]}"
        fi
    done
    success "  All ${#CLABS_HASHES[@]} cLabs hashes match for $version"
done

echo ""
echo "--- Council Signers ---"
for version in v4 v5 succ-v2; do
    echo "  Version: $version"
    COUNCIL_HASHES=()
    for signer_dir in "${COUNCIL_SIGNERS[@]}"; do
        sig_file=$(find "$signer_dir" -name "out-${version}*" -type f 2>/dev/null | head -1)
        if [ -z "$sig_file" ]; then
            error "No signature file for $version in $signer_dir"
        fi
        account=$(jq -r '.account' "$sig_file")
        hash=$(jq -r '.hash' "$sig_file")
        sig_version=$(jq -r '.version' "$sig_file")
        COUNCIL_HASHES+=("$hash")
        if [ "$sig_version" != "$version" ]; then
            error "Version mismatch in $sig_file: expected $version, got $sig_version"
        fi
        success "  $sig_file: account=$account, hash=$hash"
    done

    # Verify ALL hashes match each other
    for i in "${!COUNCIL_HASHES[@]}"; do
        if [ "${COUNCIL_HASHES[$i]}" != "${COUNCIL_HASHES[0]}" ]; then
            error "Council signature hashes don't match for $version: ${COUNCIL_HASHES[0]} vs ${COUNCIL_HASHES[$i]}"
        fi
    done
    success "  All ${#COUNCIL_HASHES[@]} Council hashes match for $version"
done

echo ""
echo "--- Verifying ALL signers are on-chain owners ---"
for signer_dir in "${CLABS_SIGNERS[@]}"; do
    sig_file=$(find "$signer_dir" -name "out-v4*" -type f 2>/dev/null | head -1)
    addr=$(jq -r '.account' "$sig_file")
    validate_signer_is_owner "$addr" "$CLABS_SAFE" "cLabs Safe"
done
for signer_dir in "${COUNCIL_SIGNERS[@]}"; do
    sig_file=$(find "$signer_dir" -name "out-v4*" -type f 2>/dev/null | head -1)
    addr=$(jq -r '.account' "$sig_file")
    validate_signer_is_owner "$addr" "$COUNCIL_SAFE" "Council Safe"
done

success "All ${#CLABS_SIGNERS[@]} cLabs + ${#COUNCIL_SIGNERS[@]} Council signatures validated!"

# =============================================================================
# STEP 3: Lower Safe thresholds
# =============================================================================
echo ""
log "STEP 3: Lowering Safe thresholds..."

# cLabs: 6 → 4 (we have 4 signers: Javi, Karl, Paul, Pavel)
cast rpc anvil_setStorageAt "$CLABS_SAFE" "$THRESHOLD_SLOT" \
    "0x0000000000000000000000000000000000000000000000000000000000000004" --rpc-url "$R" > /dev/null
NEW_THRESH=$(cast call "$CLABS_SAFE" "getThreshold()(uint256)" --rpc-url "$R")
success "cLabs Safe threshold: 6 → $NEW_THRESH"

# Council: 6 → 5 (we have 5 signers: Aaron, Kris, Luca, Nam, Silas)
cast rpc anvil_setStorageAt "$COUNCIL_SAFE" "$THRESHOLD_SLOT" \
    "0x0000000000000000000000000000000000000000000000000000000000000005" --rpc-url "$R" > /dev/null
NEW_THRESH=$(cast call "$COUNCIL_SAFE" "getThreshold()(uint256)" --rpc-url "$R")
success "Council Safe threshold: 6 → $NEW_THRESH"

# =============================================================================
# Helper: sort signatures by address
# =============================================================================
sort_and_concat_sigs() {
    local -a pairs=()
    while [ $# -gt 0 ]; do
        local addr="$1"
        local sig="$2"
        pairs+=("$(echo "$addr" | tr '[:upper:]' '[:lower:]'):$sig")
        shift 2
    done

    IFS=$'\n' sorted=($(printf '%s\n' "${pairs[@]}" | sort))
    unset IFS

    local result=""
    for pair in "${sorted[@]}"; do
        local sig="${pair#*:}"
        result="${result}${sig}"
    done
    echo "$result"
}

# Build pre-approved signature for parent Safe (v=1 format)
# Parent owners sorted: cLabs (0x9Eb4) < Council (0xC031)
build_parent_signatures() {
    local clabs_padded
    clabs_padded=$(echo "$CLABS_SAFE" | sed 's/0x//' | tr '[:upper:]' '[:lower:]')
    clabs_padded=$(printf '%064s' "$clabs_padded" | tr ' ' '0')

    local council_padded
    council_padded=$(echo "$COUNCIL_SAFE" | sed 's/0x//' | tr '[:upper:]' '[:lower:]')
    council_padded=$(printf '%064s' "$council_padded" | tr ' ' '0')

    local zeros="0000000000000000000000000000000000000000000000000000000000000000"

    # cLabs < Council by address, so cLabs first
    echo "0x${clabs_padded}${zeros}01${council_padded}${zeros}01"
}

# =============================================================================
# STEP 4: Execute upgrades
# =============================================================================

execute_version() {
    local VERSION="$1"
    echo ""
    echo "========================================================================="
    log "Executing $VERSION"
    echo "========================================================================="

    # Load upgrade data
    local UPGRADE_FILE
    UPGRADE_FILE=$(ls "upgrades/mainnet/"*"-${VERSION}.json" 2>/dev/null)
    if [ -z "$UPGRADE_FILE" ]; then
        error "No upgrade file found for $VERSION"
    fi

    local TARGET CALLDATA PARENT_NONCE CLABS_NONCE COUNCIL_NONCE
    TARGET=$(jq -r '.target' "$UPGRADE_FILE")
    CALLDATA=$(jq -r '.calldata' "$UPGRADE_FILE")
    PARENT_NONCE=$(jq -r '.nonce.parent' "$UPGRADE_FILE")
    CLABS_NONCE=$(jq -r '.nonce.clabs' "$UPGRADE_FILE")
    COUNCIL_NONCE=$(jq -r '.nonce.council' "$UPGRADE_FILE")

    echo "  Target: $TARGET"
    echo "  Parent nonce: $PARENT_NONCE, cLabs nonce: $CLABS_NONCE, Council nonce: $COUNCIL_NONCE"

    # Verify on-chain nonces match
    local CURRENT_PARENT_NONCE CURRENT_CLABS_NONCE CURRENT_COUNCIL_NONCE
    CURRENT_PARENT_NONCE=$(cast call "$PARENT_SAFE" "nonce()(uint256)" --rpc-url "$R")
    CURRENT_CLABS_NONCE=$(cast call "$CLABS_SAFE" "nonce()(uint256)" --rpc-url "$R")
    CURRENT_COUNCIL_NONCE=$(cast call "$COUNCIL_SAFE" "nonce()(uint256)" --rpc-url "$R")

    if [ "$CURRENT_PARENT_NONCE" != "$PARENT_NONCE" ]; then
        error "Parent nonce mismatch: on-chain=$CURRENT_PARENT_NONCE, expected=$PARENT_NONCE"
    fi
    if [ "$CURRENT_CLABS_NONCE" != "$CLABS_NONCE" ]; then
        error "cLabs nonce mismatch: on-chain=$CURRENT_CLABS_NONCE, expected=$CLABS_NONCE"
    fi
    if [ "$CURRENT_COUNCIL_NONCE" != "$COUNCIL_NONCE" ]; then
        error "Council nonce mismatch: on-chain=$CURRENT_COUNCIL_NONCE, expected=$COUNCIL_NONCE"
    fi
    success "  Nonces verified"

    # Compute parent tx hash
    local PARENT_TX_HASH
    PARENT_TX_HASH=$(cast call "$PARENT_SAFE" \
        "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
        "$TARGET" "$VALUE" "$CALLDATA" "$TX_DELEGATECALL" "$SAFE_TX_GAS" "$BASE_GAS" "$GAS_PRICE" "$GAS_TOKEN" "$REFUND_RECEIVER" "$PARENT_NONCE" \
        --rpc-url "$R"
    )
    echo "  Parent tx hash: $PARENT_TX_HASH"

    # Compute approveHash calldata
    local APPROVE_HASH_CALLDATA
    APPROVE_HASH_CALLDATA=$(cast calldata 'approveHash(bytes32)' "$PARENT_TX_HASH")

    # Compute and verify child tx hashes
    local CLABS_CHILD_TX_HASH
    CLABS_CHILD_TX_HASH=$(cast call "$CLABS_SAFE" \
        "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
        "$PARENT_SAFE" "$VALUE" "$APPROVE_HASH_CALLDATA" "$TX_CALL" "$SAFE_TX_GAS" "$BASE_GAS" "$GAS_PRICE" "$GAS_TOKEN" "$REFUND_RECEIVER" "$CLABS_NONCE" \
        --rpc-url "$R"
    )
    echo "  cLabs child tx hash: $CLABS_CHILD_TX_HASH"

    local COUNCIL_CHILD_TX_HASH
    COUNCIL_CHILD_TX_HASH=$(cast call "$COUNCIL_SAFE" \
        "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
        "$PARENT_SAFE" "$VALUE" "$APPROVE_HASH_CALLDATA" "$TX_CALL" "$SAFE_TX_GAS" "$BASE_GAS" "$GAS_PRICE" "$GAS_TOKEN" "$REFUND_RECEIVER" "$COUNCIL_NONCE" \
        --rpc-url "$R"
    )
    echo "  Council child tx hash: $COUNCIL_CHILD_TX_HASH"

    # Load ALL cLabs signatures and verify hashes
    local -a CLABS_SIG_ARGS=()
    for signer_dir in "${CLABS_SIGNERS[@]}"; do
        local sig_file
        sig_file=$(find "$signer_dir" -name "out-${VERSION}*" -type f | head -1)
        local signer_hash signer_sig signer_account
        signer_hash=$(jq -r '.hash' "$sig_file")
        signer_sig=$(jq -r '.sig' "$sig_file")
        signer_account=$(jq -r '.account' "$sig_file")

        if [ "$signer_hash" != "$CLABS_CHILD_TX_HASH" ]; then
            error "$sig_file hash doesn't match cLabs child tx hash: $signer_hash vs $CLABS_CHILD_TX_HASH"
        fi
        CLABS_SIG_ARGS+=("$signer_account" "$signer_sig")
        success "  cLabs sig verified: $signer_account ($sig_file)"
    done
    success "  All ${#CLABS_SIGNERS[@]} cLabs signature hashes verified"

    # Load ALL Council signatures and verify hashes
    local -a COUNCIL_SIG_ARGS=()
    for signer_dir in "${COUNCIL_SIGNERS[@]}"; do
        local sig_file
        sig_file=$(find "$signer_dir" -name "out-${VERSION}*" -type f | head -1)
        local signer_hash signer_sig signer_account
        signer_hash=$(jq -r '.hash' "$sig_file")
        signer_sig=$(jq -r '.sig' "$sig_file")
        signer_account=$(jq -r '.account' "$sig_file")

        if [ "$signer_hash" != "$COUNCIL_CHILD_TX_HASH" ]; then
            error "$sig_file hash doesn't match Council child tx hash: $signer_hash vs $COUNCIL_CHILD_TX_HASH"
        fi
        COUNCIL_SIG_ARGS+=("$signer_account" "$signer_sig")
        success "  Council sig verified: $signer_account ($sig_file)"
    done
    success "  All ${#COUNCIL_SIGNERS[@]} Council signature hashes verified"

    # Build cLabs signatures (sorted by address, all 4 signers)
    local CLABS_SIGS
    CLABS_SIGS=$(sort_and_concat_sigs "${CLABS_SIG_ARGS[@]}")
    CLABS_SIGS="0x${CLABS_SIGS}"

    # Execute cLabs child Safe: approveHash on parent
    log "  Executing cLabs child Safe: approveHash (${#CLABS_SIGNERS[@]} signatures)..."
    cast send --private-key "$SENDER_PK" --rpc-url "$R" --gas-limit 16000000 \
        "$CLABS_SAFE" \
        "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)(bool)" \
        "$PARENT_SAFE" "$VALUE" "$APPROVE_HASH_CALLDATA" "$TX_CALL" "$SAFE_TX_GAS" "$BASE_GAS" "$GAS_PRICE" "$GAS_TOKEN" "$REFUND_RECEIVER" "$CLABS_SIGS" \
        2>&1 | tail -5 || true

    # Verify approveHash was registered
    local CLABS_APPROVED
    CLABS_APPROVED=$(cast call "$PARENT_SAFE" "approvedHashes(address,bytes32)(uint256)" "$CLABS_SAFE" "$PARENT_TX_HASH" --rpc-url "$R")
    if [ "$CLABS_APPROVED" != "1" ]; then
        error "  cLabs approveHash NOT registered (got: $CLABS_APPROVED)"
    fi
    success "  cLabs approveHash confirmed on parent Safe"

    # Build Council signatures (sorted by address, all 3 signers)
    local COUNCIL_SIGS
    COUNCIL_SIGS=$(sort_and_concat_sigs "${COUNCIL_SIG_ARGS[@]}")
    COUNCIL_SIGS="0x${COUNCIL_SIGS}"

    # Execute Council child Safe: approveHash on parent
    log "  Executing Council child Safe: approveHash (${#COUNCIL_SIGNERS[@]} signatures)..."
    cast send --private-key "$SENDER_PK" --rpc-url "$R" --gas-limit 16000000 \
        "$COUNCIL_SAFE" \
        "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)(bool)" \
        "$PARENT_SAFE" "$VALUE" "$APPROVE_HASH_CALLDATA" "$TX_CALL" "$SAFE_TX_GAS" "$BASE_GAS" "$GAS_PRICE" "$GAS_TOKEN" "$REFUND_RECEIVER" "$COUNCIL_SIGS" \
        2>&1 | tail -5 || true

    local COUNCIL_APPROVED
    COUNCIL_APPROVED=$(cast call "$PARENT_SAFE" "approvedHashes(address,bytes32)(uint256)" "$COUNCIL_SAFE" "$PARENT_TX_HASH" --rpc-url "$R")
    if [ "$COUNCIL_APPROVED" != "1" ]; then
        error "  Council approveHash NOT registered (got: $COUNCIL_APPROVED)"
    fi
    success "  Council approveHash confirmed on parent Safe"

    # Execute parent Safe: the actual upgrade
    log "  Executing parent Safe: upgrade transaction..."
    local PARENT_SIGS
    PARENT_SIGS=$(build_parent_signatures)
    echo "  Parent sigs: $PARENT_SIGS"

    local PARENT_SEND_OUTPUT
    PARENT_SEND_OUTPUT=$(cast send --private-key "$SENDER_PK" --rpc-url "$R" --gas-limit 16000000 \
        "$PARENT_SAFE" \
        "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)(bool)" \
        "$TARGET" "$VALUE" "$CALLDATA" "$TX_DELEGATECALL" "$SAFE_TX_GAS" "$BASE_GAS" "$GAS_PRICE" "$GAS_TOKEN" "$REFUND_RECEIVER" "$PARENT_SIGS" \
        2>&1) || true
    echo "  Parent send output: $PARENT_SEND_OUTPUT"

    # Verify nonce incremented
    local NEW_PARENT_NONCE
    NEW_PARENT_NONCE=$(cast call "$PARENT_SAFE" "nonce()(uint256)" --rpc-url "$R")
    local EXPECTED_NONCE=$((PARENT_NONCE + 1))
    if [ "$NEW_PARENT_NONCE" = "$EXPECTED_NONCE" ]; then
        success "  Parent nonce incremented: $PARENT_NONCE → $NEW_PARENT_NONCE"
    else
        error "  Parent nonce unexpected: $NEW_PARENT_NONCE (expected $EXPECTED_NONCE)"
    fi

    success "$VERSION execution complete!"
}

# Execute each version in order
for version in v4 v5 succ-v2; do
    execute_version "$version"
done

# =============================================================================
# STEP 5: Post-execution verification
# =============================================================================
echo ""
echo "========================================================================="
log "Post-execution verification"
echo "========================================================================="

FINAL_PARENT_NONCE=$(cast call "$PARENT_SAFE" "nonce()(uint256)" --rpc-url "$R")
FINAL_CLABS_NONCE=$(cast call "$CLABS_SAFE" "nonce()(uint256)" --rpc-url "$R")
FINAL_COUNCIL_NONCE=$(cast call "$COUNCIL_SAFE" "nonce()(uint256)" --rpc-url "$R")

echo "  Final nonces: Parent=$FINAL_PARENT_NONCE (exp 29), cLabs=$FINAL_CLABS_NONCE (exp 27), Council=$FINAL_COUNCIL_NONCE (exp 29)"

# succ-v2: check DisputeGameFactory.gameImpls(42)
DGF="0xFbAC162162f4009Bb007C6DeBC36B1dAC10aF683"
GAME_IMPL=$(cast call "$DGF" "gameImpls(uint32)(address)" 42 --rpc-url "$R")
EXPECTED_IMPL="0xE7bd695d6A17970A2D9dB55cfeF7F2024d630aE1"
echo "  DisputeGameFactory.gameImpls(42): $GAME_IMPL"
if [ "$(echo "$GAME_IMPL" | tr '[:upper:]' '[:lower:]')" = "$(echo "$EXPECTED_IMPL" | tr '[:upper:]' '[:lower:]')" ]; then
    success "  DisputeGameFactory implementation updated correctly"
else
    warn "  DisputeGameFactory implementation: $GAME_IMPL (expected $EXPECTED_IMPL)"
fi

# succ-v2: check SystemConfig.owner()
SYSTEM_CONFIG="0x89E31965D844a309231B1f17759Ccaf1b7c09861"
SC_OWNER=$(cast call "$SYSTEM_CONFIG" "owner()(address)" --rpc-url "$R")
echo "  SystemConfig.owner(): $SC_OWNER"
if [ "$(echo "$SC_OWNER" | tr '[:upper:]' '[:lower:]')" = "$(echo "$CLABS_SAFE" | tr '[:upper:]' '[:lower:]')" ]; then
    success "  SystemConfig ownership transferred to cLabs Safe"
else
    warn "  SystemConfig owner: $SC_OWNER (expected $CLABS_SAFE)"
fi

echo ""
echo "========================================================================="
success "ALL UPGRADES EXECUTED SUCCESSFULLY ON ANVIL FORK!"
echo "========================================================================="
