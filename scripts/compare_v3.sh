#!/bin/bash

# This script compares the bytecode of contracts listed in addresses/v3.json
# with the bytecode from forge artifacts.
#
# Usage: ./scripts/compare_v3.sh <path_to_forge_artifacts_folder>

set -e

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_forge_artifacts_folder>"
    exit 1
fi

FORGE_ARTIFACTS_DIR=$1

# Call the main compare script with the hardcoded JSON file
./scripts/compare_release.sh addresses/v3.json $FORGE_ARTIFACTS_DIR
