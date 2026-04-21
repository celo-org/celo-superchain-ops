#!/bin/bash

# Usage: ./scripts/compare.sh <version> <path_to_forge_artifacts_folder>

set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <version> <path_to_forge_artifacts_folder>"
    exit 1
fi

VERSION=$1
FORGE_ARTIFACTS_DIR=$2
NETWORK=${NETWORK:-mainnet}
ADDRESSES_FILE=$(ls addresses/${NETWORK}/[0-9][0-9]-${VERSION}.json 2>/dev/null)

if ! command -v jq &> /dev/null; then
    echo "jq could not be found, please install it."
    exit 1
fi

if [ -z "$ADDRESSES_FILE" ]; then
    echo "Error: No addresses file found for $VERSION on $NETWORK"
    exit 1
fi

if [ ! -d "$FORGE_ARTIFACTS_DIR" ]; then
    echo "Error: Forge artifacts directory not found at $FORGE_ARTIFACTS_DIR"
    exit 1
fi

case $VERSION in
succ-v1|succ-v102|succ-v2|succ-v201)
    echo "============================================="
    echo "OpSuccinct Contract Verification ($VERSION)"
    echo "============================================="
    echo ""
    echo "The OpSuccinct contracts were deployed using CREATE3"
    echo "deterministic deployment to pre-calculated addresses:"
    echo ""
    for key in $(jq -r 'keys[]' "$ADDRESSES_FILE"); do
        addr=$(jq -r ".$key" "$ADDRESSES_FILE")
        echo "  - $key: $addr"
    done
    echo ""
    echo "This script will verify the on-chain bytecode matches"
    echo "the compiled forge artifacts."
    echo ""
    echo "Press Enter to continue with bytecode verification..."
    read
    ;;
esac

echo "Comparing contracts from $ADDRESSES_FILE"
echo "Using artifacts from $FORGE_ARTIFACTS_DIR"
echo ""

ok_contracts=()
failed_contracts=()

for key in $(jq -r 'keys[]' "$ADDRESSES_FILE"); do
    address=$(jq -r ".$key" "$ADDRESSES_FILE")
    contract_name=$(echo $key | sed 's/Impl$//' | sed 's/Singleton$//')
    artifact_path="$FORGE_ARTIFACTS_DIR/$contract_name.sol/$contract_name.json"

    if [ ! -f "$artifact_path" ]; then
        echo "----------------------------------------"
        echo "FAILED: $key"
        echo "Artifact not found at: $artifact_path"
        echo "----------------------------------------"
        failed_contracts+=("$key")
        continue
    fi

    echo "----------------------------------------"
    echo "Comparing $key ($contract_name)"
    echo "Address: $address"
    echo "Artifact: $artifact_path"

    if output=$(./scripts/compare_bytecode.sh "$address" "$artifact_path" 2>&1); then
        echo "$output"
        ok_contracts+=("$key")
    else
        echo "$output"
        failed_contracts+=("$key")
    fi

    echo "----------------------------------------"
    echo ""
done

echo "Comparison Summary:"
if [ ${#failed_contracts[@]} -gt 0 ]; then
    printf "\e[31mThe following contracts FAILED the check:\e[0m\n"
    for contract in "${failed_contracts[@]}"; do
        printf -- "- %s\n" "$contract"
    done

    if [ ${#ok_contracts[@]} -gt 0 ]; then
        printf "\e[32mThe following contracts are OK:\e[0m\n"
        for contract in "${ok_contracts[@]}"; do
            printf -- "- %s\n" "$contract"
        done
    fi
    exit 1
else
    printf "\e[32mAll %s contracts are OK.\e[0m\n" "${#ok_contracts[@]}"
fi

echo ""
echo "All contracts compared."
