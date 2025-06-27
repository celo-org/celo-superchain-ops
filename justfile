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

    FROM=$(cast wallet address --private-key $SENDER_PK)
    OPCM=$(cat upgrades/$VERSION.json | jq -r .opcm)
    PARENT_CALLDATA=$(cat upgrades/$VERSION.json | jq -r .calldata)
    echo "Link to Tenderly sim: https://dashboard.tenderly.co/TENDERLY_USERNAME/TENDERLY_PROJECT/simulator/new?network=1&contractAddress=$OPCM&from=$FROM&rawFunctionInput=$PARENT_CALLDATA"

sign version team hd_path:
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
    CHILD_TX_HASH=$(cast call $CHILD_SAFE_ADDRESS \
        "getTransactionHash(address,uint256,bytes,uint8,uint256,uint256,uint256,address,address,uint256)(bytes32)" \
        $PARENT_SAFE_ADDRESS $VALUE $CHILD_CALLDATA $OP_CALL $SAFE_TX_GAS $BASE_GAS $GAS_PRICE $GAS_TOKEN $REFUND_RECEIVER $CHILD_NONCE \
        -r $RPC_URL
    )
    echo "Child tx hash: $CHILD_TX_HASH"

    if [ -z ${HD_PATH:-} ]; then
        echo "Signing Ledger wallet under default derivation path..."
        SIG=$(cast wallet sign --ledger $CHILD_TX_HASH)
    else
        echo "Signing Ledger wallet under $HD_PATH derivation path..."
        SIG=$(cast wallet sign --ledger --hd-path "$HD_PATH" $CHILD_TX_HASH)
    fi
    echo "Your signature for child tx hash: $SIG"

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
