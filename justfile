set dotenv-load := true

# Network selection (mainnet, sepolia)
NETWORK := env_var_or_default("NETWORK", "mainnet")

export VALUE := "0"
export TX_CALL := "0"
export TX_DELEGATECALL := "1"
export SAFE_TX_GAS := "0"
export BASE_GAS := "0"
export GAS_PRICE := "0"
export GAS_TOKEN := "0x0000000000000000000000000000000000000000"
export REFUND_RECEIVER := "0x95ffac468e37ddeef407ffef18f0cc9e86d8f13b"

default:
    just --list

install-eip712sign:
    #!/usr/bin/env bash
    set -euo pipefail
    REPO_ROOT=$(git rev-parse --show-toplevel)
    GOBIN="${REPO_ROOT}" go install github.com/base/eip712sign@v0.0.11

check-network network:
    #!/usr/bin/env bash
    set -euo pipefail

    NETWORK={{network}}
    case $NETWORK in
    "mainnet"|"sepolia")
        echo "Detected network: $NETWORK"
        ;;
    *)
        echo "Invalid network: $NETWORK" && exit 1
        ;;
    esac

check-version version:
    #!/usr/bin/env bash
    set -euo pipefail

    VERSION={{version}}
    case $VERSION in
    "v2"|"v3"|"v4"|"v5"|"succ-v1"|"succ-v102"|"succ-v2")
        echo "Detected version: $VERSION"
        ;;
    *)
        echo "Invalid version: $VERSION" && exit 1
        ;;
    esac

check-team team:
    #!/usr/bin/env bash
    set -euo pipefail

    TEAM={{team}}
    case $TEAM in
    "clabs"|"council")
        echo "Detected team: $TEAM"
        ;;
    *)
        echo "Invalid team: $TEAM" && exit 1
        ;;
    esac

simulate version:
    #!/usr/bin/env bash
    set -euo pipefail
    
    VERSION={{version}}
    just check-version $VERSION

    NETWORK={{NETWORK}}
    just check-network $NETWORK

    case "${NETWORK}/${VERSION}" in
    "mainnet/succ-v102")
        URL="https://dashboard.tenderly.co/explorer/vnet/39498d1a-4638-47d3-8bbc-010de8f718ce/tx/0x27f7a467c7d7faa3aa9934ffc2810a4d910e2404783aed427a5fa1f732f7e12d"
        ;;
    "mainnet/succ-v1")
        URL="https://dashboard.tenderly.co/explorer/vnet/053b540e-ae59-42c8-80a0-1250820dc894/tx/0x55742ec449b9659f3a5662c5b2f6d6a92d9d955a39eeaaeaf1df1726a3f2ff3f"
        ;;
    *)
        echo "Simulation URL inactive" && exit 0
        ;;
    esac

    echo "Link to Tenderly sim: $URL"

sign version team hd_path='' grand_child='':
    #!/usr/bin/env bash
    set -euo pipefail

    NETWORK={{NETWORK}}
    just check-network $NETWORK

    case $NETWORK in
    "mainnet")
        PARENT_SAFE_ADDRESS="0x4092A77bAF58fef0309452cEaCb09221e556E112"
        CLABS_SAFE_ADDRESS="0x9Eb44Da23433b5cAA1c87e35594D15FcEb08D34d"
        COUNCIL_SAFE_ADDRESS="0xC03172263409584f7860C25B6eB4985f0f6F4636"
        REFUND_RECEIVER="0x95ffac468e37ddeef407ffef18f0cc9e86d8f13b"
        ;;
    "sepolia")
        PARENT_SAFE_ADDRESS="0x009A6Ac23EeBe98488ED28A52af69Bf46F1C18cb"
        CLABS_SAFE_ADDRESS="0x769b480A8036873a2a5EB01FE39278e5Ab78Bb27"
        COUNCIL_SAFE_ADDRESS="0x3b00043E8C82006fbE5f56b47F9889a04c20c5d6"
        RPC_URL="${SEPOLIA_RPC_URL:?Set SEPOLIA_RPC_URL in .env}"
        REFUND_RECEIVER="0x5e60d897Cd62588291656b54655e98ee73f0aabF"
        ;;
    esac

    VERSION={{version}}
    just check-version $VERSION

    TEAM={{team}}
    just check-team $TEAM

    HD_PATH="{{hd_path}}"
    GRAND_CHILD="{{grand_child}}"

    UPGRADE_FILE=$(ls upgrades/${NETWORK}/[0-9][0-9]-${VERSION}.json 2>/dev/null)
    if [ -z "$UPGRADE_FILE" ]; then echo "No upgrade file found for $VERSION" && exit 1; fi

    TARGET=$(cat $UPGRADE_FILE | jq -r .target)
    PARENT_CALLDATA=$(cat $UPGRADE_FILE | jq -r .calldata)
    PARENT_NONCE=$(cat $UPGRADE_FILE | jq -r .nonce.parent)
    PARENT_TX_HASH=$(cast call $PARENT_SAFE_ADDRESS \
        "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
        $TARGET $VALUE $PARENT_CALLDATA $TX_DELEGATECALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $PARENT_NONCE \
        -r $RPC_URL
    )
    echo "Parent tx hash: $PARENT_TX_HASH"

    CHILD_CALLDATA=$(cast calldata 'approveHash(bytes32)' $PARENT_TX_HASH)
    case $TEAM in
    "clabs")
        CHILD_SAFE_ADDRESS=$CLABS_SAFE_ADDRESS
        CHILD_NONCE=$(cat $UPGRADE_FILE | jq -r .nonce.clabs)
        ;;
    "council")
        CHILD_SAFE_ADDRESS=$COUNCIL_SAFE_ADDRESS
        CHILD_NONCE=$(cat $UPGRADE_FILE | jq -r .nonce.council)
        ;;
    esac
    CHILD_TX_HASH=$(cast call $CHILD_SAFE_ADDRESS \
        "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
        $PARENT_SAFE_ADDRESS $VALUE $CHILD_CALLDATA $TX_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $CHILD_NONCE \
        -r $RPC_URL
    )
    CHILD_TX_DATA=$(cast call $CHILD_SAFE_ADDRESS \
        "encodeTransactionData(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes)" \
        $PARENT_SAFE_ADDRESS $VALUE $CHILD_CALLDATA $TX_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $CHILD_NONCE \
        -r $RPC_URL
    )
    echo "Child tx hash: $CHILD_TX_HASH"
    echo "Child tx data: $CHILD_TX_DATA"

    if [ -z ${GRAND_CHILD:-} ]; then
        if [ -z ${TEST_PK:-} ]; then
             if [ -z ${HD_PATH:-} ]; then
                echo "Signing Ledger wallet under default derivation path..."
                echo $CHILD_TX_DATA | ./eip712sign -ledger > .tmp
            else
                echo "Signing Ledger wallet under $HD_PATH derivation path..."
                echo $CHILD_TX_DATA | ./eip712sign -ledger -hd-paths "$HD_PATH" > .tmp
            fi
        else
            echo $CHILD_TX_DATA | ./eip712sign -private-key ${TEST_PK:2} > .tmp
        fi
    else
        echo "Attempting to generate payload for grand child at: $GRAND_CHILD"
        GRAND_CHILD_VERSION=$(cast call $GRAND_CHILD "VERSION()(string)" -r $RPC_URL)
        GRAND_CHILD_NONCE=$(cat $UPGRADE_FILE | jq -r .nonce.grand_child)
        echo "Detected grand child at version: $GRAND_CHILD_VERSION with nonce: $GRAND_CHILD_NONCE"

        GRAND_CHILD_CALLDATA=$(cast calldata 'approveHash(bytes32)' $CHILD_TX_HASH)
        GRAND_CHILD_TX_HASH=$(cast call $GRAND_CHILD \
            "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
            $CHILD_SAFE_ADDRESS $VALUE $GRAND_CHILD_CALLDATA $TX_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $GRAND_CHILD_NONCE \
            -r $RPC_URL
        )
        GRAND_CHILD_TX_DATA=$(cast call $GRAND_CHILD \
            "encodeTransactionData(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes)" \
            $CHILD_SAFE_ADDRESS $VALUE $GRAND_CHILD_CALLDATA $TX_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $GRAND_CHILD_NONCE \
            -r $RPC_URL
        )
        echo "Grand child tx hash: $GRAND_CHILD_TX_HASH"
        echo "Grand child tx data: $GRAND_CHILD_TX_DATA"

        if [ -z ${TEST_PK:-} ]; then
             if [ -z ${HD_PATH:-} ]; then
                echo "Signing Ledger wallet under default derivation path..."
                echo $GRAND_CHILD_TX_DATA | ./eip712sign -ledger > .tmp
            else
                echo "Signing Ledger wallet under $HD_PATH derivation path..."
                echo $GRAND_CHILD_TX_DATA | ./eip712sign -ledger -hd-paths "$HD_PATH" > .tmp
            fi
        else
            echo $GRAND_CHILD_TX_DATA | ./eip712sign -private-key ${TEST_PK:2} > .tmp
        fi
    fi
    
    ACCOUNT=$(cat .tmp | grep Signer)
    ACCOUNT="${ACCOUNT#Signer: }"
    echo "Your account is $ACCOUNT"

    SIG=$(cat .tmp | grep Signature)
    SIG="${SIG#Signature: }"
    if [ -z ${GRAND_CHILD:-} ]; then
        echo "Your signature for child tx hash: $SIG"
    else
        echo "Your signature for grand child tx hash: $SIG"
    fi

    if [ -z ${GRAND_CHILD:-} ]; then
        just create_json $VERSION $CHILD_TX_HASH $CHILD_TX_DATA $SIG $ACCOUNT
    else
        just create_json $VERSION $GRAND_CHILD_TX_HASH $GRAND_CHILD_TX_DATA $SIG $ACCOUNT
    fi

sign_all team hd_path='' grand_child='':
    #!/usr/bin/env bash
    set -euo pipefail

    VERSIONS=("v4" "v5" "succ-v2")

    for VERSION in "${VERSIONS[@]}"; do
        echo ""
        echo "========================================="
        echo "  Signing: $VERSION"
        echo "========================================="
        echo ""
        just sign $VERSION {{team}} "{{hd_path}}" "{{grand_child}}"
        mv out.json out-${VERSION}.json
        echo "Saved to out-${VERSION}.json"
    done

    echo ""
    echo "========================================="
    echo "  All signatures collected"
    echo "========================================="
    for VERSION in "${VERSIONS[@]}"; do
        echo "  $VERSION -> out-${VERSION}.json"
    done
    echo ""
    echo "Send all out-*.json files to the facilitator."

sign_all_ledger team ledger_app account_index='0' grand_child='':
    #!/usr/bin/env bash
    set -euo pipefail

    LEDGER_APP="{{ledger_app}}"
    ACCOUNT_INDEX="{{account_index}}"

    case $LEDGER_APP in
    "celo")
        HD_PATH="m/44'/52752'/$ACCOUNT_INDEX'/0/0"
        ;;
    "eth")
        HD_PATH="m/44'/60'/$ACCOUNT_INDEX'/0/0"
        ;;
    *)
        echo "Invalid ledger_app: $LEDGER_APP. Must be 'celo' or 'eth'." && exit 1
        ;;
    esac

    just sign_all {{team}} "$HD_PATH" {{grand_child}}

sign_ledger version team ledger_app account_index='0' grand_child='':
    #!/usr/bin/env bash
    set -euo pipefail

    LEDGER_APP="{{ledger_app}}"
    ACCOUNT_INDEX="{{account_index}}"

    case $LEDGER_APP in
    "celo")
        HD_PATH="m/44'/52752'/$ACCOUNT_INDEX'/0/0"
        ;;
    "eth")
        HD_PATH="m/44'/60'/$ACCOUNT_INDEX'/0/0"
        ;;
    *)
        echo "Invalid ledger_app: $LEDGER_APP. Must be 'celo' or 'eth'." && exit 1
        ;;
    esac

    just sign {{version}} {{team}} "$HD_PATH" {{grand_child}}

create_json version hash data sig account:
    echo "{\"version\": \"{{version}}\", \"network\": \"{{NETWORK}}\", \"hash\": \"{{hash}}\", \"data\": \"{{data}}\", \"sig\": \"{{sig}}\", \"account\": \"{{account}}\"}" > out.json

print_json grand_child='':
    #!/usr/bin/env bash
    set -euo pipefail
    GRAND_CHILD={{grand_child}}
    if [ -z ${GRAND_CHILD:-} ]; then
        echo -e "\e[1;33mCopy and forward following JSON to your facilitator:\e[0m"
    else
        echo -e \
            "\e[1;33mImportant! Your signer is a nested Gnosis Safe wallet.\n" \
            "Regular path supports structure: (Celo Multisig) > (Council Multisig) > (Hardware Wallet).\n" \
            "Your structure is as following: (Celo Multisig) > (Council Multisig) > (Nested Multisig) > (Your Wallet).\n" \
            "Ensure required number of members within your nested Gnosis Safe wallet will run this script.\n" \
            "Copy and forward full output of current script and following JSON to your facilitator:\e[0m"
    fi
    cat out.json | jq


