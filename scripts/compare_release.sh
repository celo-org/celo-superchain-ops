#!/bin/bash

# This script compares the bytecode of contracts listed in a JSON file with
# the bytecode from forge artifacts.
# 
# Usage: ./scripts/compare_release.sh <path_to_json_file> <path_to_forge_artifacts_folder>

# Arrays to store comparison results
ok_contracts=()
failed_contracts=()

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path_to_json_file> <path_to_forge_artifacts_folder>"
    exit 1
fi

JSON_FILE=$1
FORGE_ARTIFACTS_DIR=$2

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install it."
    exit 1
fi

# Check if the JSON file exists
if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file not found at $JSON_FILE"
    exit 1
fi

# Check if the forge artifacts directory exists
if [ ! -d "$FORGE_ARTIFACTS_DIR" ]; then
    echo "Error: Forge artifacts directory not found at $FORGE_ARTIFACTS_DIR"
    exit 1
fi

echo "Comparing contracts from $JSON_FILE"
echo "Using artifacts from $FORGE_ARTIFACTS_DIR"
echo ""

# Iterate over the keys in the JSON file
for key in $(jq -r 'keys[]' $JSON_FILE); do
    # Get the address for the current key
    address=$(jq -r ".$key" $JSON_FILE)

    # Determine the contract name by removing Impl or Singleton suffix
    contract_name=$(echo $key | sed 's/Impl$//' | sed 's/Singleton$//')

    # Construct the path to the artifact JSON file
    artifact_path="$FORGE_ARTIFACTS_DIR/$contract_name.sol/$contract_name.json"

    if [ ! -f "$artifact_path" ]; then
        echo "----------------------------------------"
        echo "SKIPPING: $key"
        echo "Artifact not found at: $artifact_path"
        echo "----------------------------------------"
        continue
    fi

    echo "----------------------------------------"
    echo "Comparing $key ($contract_name)"
    echo "Address: $address"
    echo "Artifact: $artifact_path"
    
    # Call the compare_bytecode.sh script and check its exit code
    if output=$(./scripts/compare_bytecode.sh $address $artifact_path 2>&1); then
        echo "$output"
        ok_contracts+=("$key")
    else
        echo "$output"
        failed_contracts+=("$key")
    fi
    
    echo "----------------------------------------"
    echo ""
done

# Summary
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
