#!/bin/bash

# This script compares the bytecode of contracts listed in addresses/succinct.json
# with the bytecode from forge artifacts.
#
# NOTE: The OpSuccinct contracts were deployed using deterministic CREATE3 deployment.
# The addresses in addresses/succinct.json are for the pre-deployed contracts on mainnet.
# This script verifies that the on-chain bytecode matches the compiled artifacts.
#
# Usage: ./scripts/compare_succinct.sh <path_to_forge_artifacts_folder>

set -e

# Check if the correct number of arguments are provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path_to_forge_artifacts_folder>"
    exit 1
fi

FORGE_ARTIFACTS_DIR=$1

# Display information about deployed contracts
echo "============================================="
echo "OpSuccinct Contract Verification"
echo "============================================="
echo ""
echo "The OpSuccinct contracts were deployed using CREATE3"
echo "deterministic deployment to pre-calculated addresses:"
echo ""
echo "  - AccessManager: 0xf59a19c5578291cb7fd22618d16281adf76f2816"
echo "  - OPSuccinctFaultDisputeGame: 0x113f434f82ff82678ae7f69ea122791fe1f6b73e"
echo ""
echo "This script will verify the on-chain bytecode matches"
echo "the compiled forge artifacts."
echo ""
echo "Press Enter to continue with bytecode verification..."
read

# Call the main compare script with the hardcoded JSON file
./scripts/compare_release.sh addresses/succinct.json $FORGE_ARTIFACTS_DIR
