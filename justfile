set dotenv-load := true

export PARENT_SAFE_ADDRESS := "0x4092A77bAF58fef0309452cEaCb09221e556E112"
export CLABS_SAFE_ADDRESS := "0x9Eb44Da23433b5cAA1c87e35594D15FcEb08D34d"
export COUNCIL_SAFE_ADDRESS := "0xC03172263409584f7860C25B6eB4985f0f6F4636"

export VALUE := "0"
export OP_CALL := "0"
export OP_DELEGATECALL := "1"
export SAFE_TX_GAS := "0"
export BASE_GAS := "0"
export GAS_PRICE := "0"
export GAS_TOKEN := "0x0000000000000000000000000000000000000000"
export REFUND_RECEIVER := "0x0000000000000000000000000000000000000000"

default:
    just --list

install-eip712sign:
    #!/usr/bin/env bash
    set -euo pipefail
    REPO_ROOT=$(git rev-parse --show-toplevel)
    GOBIN="${REPO_ROOT}" go install github.com/base/eip712sign@v0.0.11

check-version version:
    #!/usr/bin/env bash
    set -euo pipefail

    VERSION={{version}}
    case $VERSION in
    "v2"|"v3")
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

    if [ $VERSION = "v2" ]; then
        URL="https://dashboard.tenderly.co/explorer/vnet/4c92d88c-598f-42fd-bfdc-c837b8d697cc/tx/0x7c44fe8c5c48931a322f0b986957c677b8871922ab152307e06f7319cd85f639"
    else
        URL="https://dashboard.tenderly.co/explorer/vnet/4c92d88c-598f-42fd-bfdc-c837b8d697cc/tx/0x8d37735f7be725450d35187ea24f9050341a601817a2152c6fefa7a1192597da"
    fi
    echo "Link to Tenderly sim: $URL"

sign version team hd_path='' grand_child='':
    #!/usr/bin/env bash
    set -euo pipefail

    VERSION={{version}}
    just check-version $VERSION

    TEAM={{team}}
    just check-team $TEAM

    HD_PATH="{{hd_path}}"
    GRAND_CHILD="{{grand_child}}"

    OPCM=$(cat upgrades/$VERSION.json | jq -r .opcm)
    PARENT_CALLDATA=$(cat upgrades/$VERSION.json | jq -r .calldata)
    PARENT_NONCE=$(cat upgrades/$VERSION.json | jq -r .nonce.parent)
    PARENT_TX_HASH=$(cast call $PARENT_SAFE_ADDRESS \
        "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
        $OPCM $VALUE $PARENT_CALLDATA $OP_DELEGATECALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $PARENT_NONCE \
        -r $RPC_URL
    )
    echo "Parent tx hash: $PARENT_TX_HASH"

    CHILD_CALLDATA=$(cast calldata 'approveHash(bytes32)' $PARENT_TX_HASH)
    case $TEAM in
    "clabs")
        CHILD_SAFE_ADDRESS=$CLABS_SAFE_ADDRESS
        CHILD_NONCE=$(cat upgrades/$VERSION.json | jq -r .nonce.clabs)
        ;;
    "council")
        CHILD_SAFE_ADDRESS=$COUNCIL_SAFE_ADDRESS
        CHILD_NONCE=$(cat upgrades/$VERSION.json | jq -r .nonce.council)
        ;;
    esac
    CHILD_TX_HASH=$(cast call $CHILD_SAFE_ADDRESS \
        "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
        $PARENT_SAFE_ADDRESS $VALUE $CHILD_CALLDATA $OP_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $CHILD_NONCE \
        -r $RPC_URL
    )
    CHILD_TX_DATA=$(cast call $CHILD_SAFE_ADDRESS \
        "encodeTransactionData(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes)" \
        $PARENT_SAFE_ADDRESS $VALUE $CHILD_CALLDATA $OP_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $CHILD_NONCE \
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
        if [ $VERSION = "v2" ]; then
            # GRAND_CHILD_NONCE=$(cast call $GRAND_CHILD "nonce()(uint256)" -r $RPC_URL)
            GRAND_CHILD_NONCE=2
        else
            # GRAND_CHILD_NONCE=$(cast call $GRAND_CHILD "nonce()(uint256)" -r $RPC_URL)
            # GRAND_CHILD_NONCE=$(($GRAND_CHILD_NONCE + 1))
            GRAND_CHILD_NONCE=3
        fi
        echo "Detected grand child at version: $GRAND_CHILD_VERSION with nonce: $GRAND_CHILD_NONCE"

        GRAND_CHILD_CALLDATA=$(cast calldata 'approveHash(bytes32)' $CHILD_TX_HASH)
        GRAND_CHILD_TX_HASH=$(cast call $GRAND_CHILD \
            "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
            $CHILD_SAFE_ADDRESS $VALUE $GRAND_CHILD_CALLDATA $OP_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $GRAND_CHILD_NONCE \
            -r $RPC_URL
        )
        GRAND_CHILD_TX_DATA=$(cast call $GRAND_CHILD \
            "encodeTransactionData(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes)" \
            $CHILD_SAFE_ADDRESS $VALUE $GRAND_CHILD_CALLDATA $OP_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $GRAND_CHILD_NONCE \
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

    if [ ! -f out.json ]; then
        just create_json 0x0 0x0 0x0 0x0 0x0 0x0 0x0
    fi

    case $VERSION in
    "v2")
        V3_HASH=$(cat out.json | jq -r .v3_hash)
        V3_DATA=$(cat out.json | jq -r .v3_data)
        V3_SIG=$(cat out.json | jq -r .v3_sig)
        if [ -z ${GRAND_CHILD:-} ]; then
            just create_json $CHILD_TX_HASH $CHILD_TX_DATA $SIG $V3_HASH $V3_DATA $V3_SIG $ACCOUNT
        else
            just create_json $GRAND_CHILD_TX_HASH $GRAND_CHILD_TX_DATA $SIG $V3_HASH $V3_DATA $V3_SIG $ACCOUNT
        fi
        ;;
    "v3")
        V2_HASH=$(cat out.json | jq -r .v2_hash)
        V2_DATA=$(cat out.json | jq -r .v2_data)
        V2_SIG=$(cat out.json | jq -r .v2_sig)
        if [ -z ${GRAND_CHILD:-} ]; then
            just create_json $V2_HASH $V2_DATA $V2_SIG $CHILD_TX_HASH $CHILD_TX_DATA $SIG $ACCOUNT
        else
            just create_json $V2_HASH $V2_DATA $V2_SIG $GRAND_CHILD_TX_HASH $GRAND_CHILD_TX_DATA $SIG $ACCOUNT
        fi
        ;;
    esac

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

create_json v2_hash v2_data v2_sig v3_hash v3_data v3_sig account:
    echo "{\"v2_hash\": \"{{v2_hash}}\", \"v2_data\": \"{{v2_data}}\", \"v2_sig\": \"{{v2_sig}}\", \"v3_hash\": \"{{v3_hash}}\", \"v3_data\": \"{{v3_data}}\", \"v3_sig\": \"{{v3_sig}}\", \"account\": \"{{account}}\"}" > out.json

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

sign_all team hd_path='' grand_child='':
    #!/usr/bin/env bash
    set -euo pipefail
    HD_PATH={{hd_path}}
    just sign v2 {{team}} "$HD_PATH" {{grand_child}}
    just sign v3 {{team}} "$HD_PATH" {{grand_child}}
    just print_json {{grand_child}}

sign_all_ledger team ledger_app account_index='0' grand_child='':
    just sign_ledger v2 {{team}} {{ledger_app}} {{account_index}} {{grand_child}}
    just sign_ledger v3 {{team}} {{ledger_app}} {{account_index}} {{grand_child}}
    just print_json {{grand_child}}

exec safe to calldata op sig:
    #!/usr/bin/env bash
    set -euo pipefail

    SAFE={{safe}}
    TO={{to}}
    CALLDATA={{calldata}}
    OP={{op}}
    SIG={{sig}}

    cast send $SAFE \
        "execTransaction(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,bytes)" \
        $TO $VALUE $CALLDATA $OP $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $SIG \
        --private-key $SENDER_PK \
        -r $RPC_URL
