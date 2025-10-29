#!/bin/bash

# This script compares the bytecode of contracts listed in addresses/succinct.json
# with the bytecode from forge artifacts.
#
# NOTE: The OpSuccinct contracts use deterministic CREATE3 deployment. The addresses
# in addresses/succinct.json are pre-calculated but NOT YET DEPLOYED on mainnet.
# This script will work properly only after the contracts are deployed.
#
# Usage: ./scripts/compare_succinct.sh <path_to_forge_artifacts_folder>

set -e

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_forge_artifacts_folder>"
    exit 1
fi

FORGE_ARTIFACTS_DIR=$1

# Display warning about pre-deployment status
echo "=========================================="
echo "WARNING: OpSuccinct Pre-Deployment Check"
echo "=========================================="
echo ""
echo "The OpSuccinct upgrade uses CREATE3 deterministic deployment."
echo "Addresses are pre-calculated but contracts are NOT YET DEPLOYED."
echo ""
echo "This script will verify bytecode AFTER deployment completes."
echo "Until deployment, you can verify:"
echo "  1. The forge artifacts match expected contracts"
echo "  2. The CREATE3 address calculation (see op-succinct repo)"
echo ""
echo "Press Enter to continue with forge artifact verification..."
read

# Call the main compare script with the hardcoded JSON file
./scripts/compare_release.sh addresses/succinct.json $FORGE_ARTIFACTS_DIR
