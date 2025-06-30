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

sign version team hd_path='':
    #!/usr/bin/env bash
    set -euo pipefail

    VERSION={{version}}
    just check-version $VERSION

    TEAM={{team}}
    just check-team $TEAM

    HD_PATH="{{hd_path}}"

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
    CHILD_DOMAIN_HASH=$(cast call $CHILD_SAFE_ADDRESS \
        "domainSeparator()(bytes32)" \
        -r $RPC_URL
    )
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
    echo "Child domain hash: $CHILD_DOMAIN_HASH"
    echo "Child tx hash: $CHILD_TX_HASH"
    echo "Child tx data: $CHILD_TX_DATA"

    if [ -z ${HD_PATH:-} ]; then
        echo "Signing Ledger wallet under default derivation path..."
        echo $CHILD_TX_DATA | ./eip712sign -ledger > .tmp
    else
        echo "Signing Ledger wallet under $HD_PATH derivation path..."
        echo $CHILD_TX_DATA | ./eip712sign -ledger -hd-paths "$HD_PATH" > .tmp
    fi
    
    ACCOUNT=$(cat .tmp | grep Signer)
    ACCOUNT="${ACCOUNT#Signer: }"
    echo "Your account is $ACCOUNT"

    SIG=$(cat .tmp | grep Signature)
    SIG="${SIG#Signature: }"
    echo "Your signature for child tx hash: $SIG"

    if [ ! -f out.json ]; then
        just create_json 0x0 0x0 0x0
    fi

    case $VERSION in
    "v2")
        V3_SIG=$(cat out.json | jq -r .v3)
        just create_json $SIG $V3_SIG $ACCOUNT
        ;;
    "v3")
        V2_SIG=$(cat out.json | jq -r .v2)
        just create_json $V2_SIG $SIG $ACCOUNT
        ;;
    esac

sign_ledger version team ledger_app account_index='0':
    #!/usr/bin/env bash
    set -euo pipefail

    LEDGER_APP="{{ledger_app}}"
    ACCOUNT_INDEX="{{account_index}}"

    case $LEDGER_APP in
    "celo")
        HD_PATH="m/44'/52752'/0'/0/$ACCOUNT_INDEX"
        ;;
    "eth")
        HD_PATH="m/44'/60'/0'/0/$ACCOUNT_INDEX"
        ;;
    *)
        echo "Invalid ledger_app: $LEDGER_APP. Must be 'celo' or 'eth'." && exit 1
        ;;
    esac

    just sign {{version}} {{team}} "$HD_PATH"

create_json v2 v3 account:
    echo "{\"v2\": \"{{v2}}\", \"v3\": \"{{v3}}\", \"account\": \"{{account}}\"}" > out.json

print_json:
    echo "Copy and forward following JSON to your facilitator:"
    cat out.json | jq

sign_all team hd_path='':
    just sign v2 {{team}} {{hd_path}}
    just sign v3 {{team}} {{hd_path}}
    just print_json

sign_all_ledger team ledger_app account_index='0':
    just sign_ledger v2 {{team}} {{ledger_app}} {{account_index}}
    just sign_ledger v3 {{team}} {{ledger_app}} {{account_index}}
    just print_json

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
