#!/usr/bin/env bats

# randomly generated empty address
TEST_PK=0xcf14463c272869f083e36ed4a221d3c0720a0288d813c33b90734dd3cde8d9b6

# constants
ACCOUNT=0xC2F43D252b2F3868061189F876EB215Cd78108f2
GRAND_CHILD_MULTISIG=0xD1C635987B6Aa287361d08C6461491Fa9df087f2
SIM_URL_V2="https://dashboard.tenderly.co/explorer/vnet/4c92d88c-598f-42fd-bfdc-c837b8d697cc/tx/0x7c44fe8c5c48931a322f0b986957c677b8871922ab152307e06f7319cd85f639"
SIM_URL_V3="https://dashboard.tenderly.co/explorer/vnet/4c92d88c-598f-42fd-bfdc-c837b8d697cc/tx/0x8d37735f7be725450d35187ea24f9050341a601817a2152c6fefa7a1192597da"
PARENT_HASH_V2=0xb9b86bcbb08ee905a1bd6f8cc28c864c482c929093bbd9abb6dab18266f79a68
PARENT_HASH_V3=0x45d0e967c5b926f70f41bdc885f05ebc149d5f696ce3344443a793bb37cd9658

# clabs v2
CHILD_HASH_CLABS_V2=0xd8881653e5714f3c3568c6a716cb6b45f5d77d8def039cdd9e6d52cbb302a262
CHILD_DATA_CLABS_V2=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff48f02f56fe4eb00bb506a6ad4bef5b6d0f6eef36a972396624f561811a4c85faa
CHILD_SIG_CLABS_V2=276488fc40612feaa1b9cce5fe6fa7749ef42da2db623b46a3fcc78015a4f7153b3b3588ed14ca6e9140792d2ce514aa8008e65c72e758ae6a2059185a8e92b21c

# clabs v3
CHILD_HASH_CLABS_V3=0x2ba74f43c3cf09528c9c545847ba465a13d5f47c1ff0cb4c5b722ee3f2eb79d3
CHILD_DATA_CLABS_V3=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff40227bb082282eb8845b6ec60c0921ee392e40d5e3dea5ab6129e05cc282b7f56
CHILD_SIG_CLABS_V3=10c587839a6aacadf66ad717a069c5f9e2698dbda3f6394ad9fe1c5339044295489072f0a93943d9d9be0925c5acedd3102efdf2ddf5c3c8985abc3df03028b31b

# council v2
CHILD_HASH_COUNCIL_V2=0x734bd0744259664e99852c39383e03f2d939405e24d9a616bbd1ae58aa029c73
CHILD_DATA_COUNCIL_V2=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239ad5c06b2f85a0f19854cc93cc175204d1767fe80becf8e7b0ac351a3861107d92d
CHILD_SIG_COUNCIL_V2=9e6eac4b46cbab315034b8ec7d238d01e88a9295aae5ce6cf4a46489bbe5d11d1349175b5a350af5533ff1bd65e620b1114387d522c80a1026833bb8d9c972c41c

# council v3
CHILD_HASH_COUNCIL_V3=0xc04ff841e00b115a6668d57d340784fa2aa0fb0fb016410dbbbb4a8d0338a38a
CHILD_DATA_COUNCIL_V3=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239adc1c677feffb8dedab86a8233d246d8b459083aced169707b2ac5e0cdfbbc7545
CHILD_SIG_COUNCIL_V3=8801d64c3da9c2c8098db0938f2598e2b6f74f7e0a9cc37b20816a9c689bea4b2b23fc5dfed0a4fb45ffa8aadae14cdef1af6805a64a61b9ee7dea93249dc8f51b

# grand child v2
GRAND_CHILD_HASH_COUNCIL_V2=0x865ad9f32b78d2185b83af29b1ec8aa71ba8272d935388e3a725b3c421a9f9cb
GRAND_CHILD_DATA_COUNCIL_V2=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694f5d230396e7c923d32800dfbd5963f81a088fd3ec32f558f3d7743f18de8fecc9
GRAND_CHILD_SIG_COUNCIL_V2=eed5dcbdd7cdbf7712baa2f471cd1aa773ba9bae53ee262ed5b89f66f60d786a0666a13da2c28bdc506a130ccee004c51253faad9669e4c76ced8e65264f29181c

# grand child v3
GRAND_CHILD_HASH_COUNCIL_V3=0xb94d0e63f30af57aa975181f20cd48734fe4d36ee83a3bfd113bee06c1b86620
GRAND_CHILD_DATA_COUNCIL_V3=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694f2f71621dbae7f865e64de152623a941e25a3146e56733148224fed1b001eb910
GRAND_CHILD_SIG_COUNCIL_V3=14495dc61e8becf72ed08b513cd9144f1c5198be879eb81453a0adc331a999b4093894064353bbf8f9ffa65eff707c61b571c375ff2ae33075ed9698611f09071b

@test "Test default command" {
  run just
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Available recipes:" ]
}

@test "Test check-version v2" {
  run just check-version v2
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
}

@test "Test check-version v3" {
  run just check-version v3
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v3" ]
}

@test "Test check-version v4" {
  run just check-version v4
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Invalid version: v4" ]
}

@test "Test check-team clabs" {
  run just check-team clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected team: clabs" ]
}

@test "Test check-team council" {
  run just check-team council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected team: council" ]
}

@test "Test check-team celo" {
  run just check-team celo
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Invalid team: celo" ]
}

@test "Test simulate v2" {
  run just simulate v2
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Link to Tenderly sim: $SIM_URL_V2" ]
}

@test "Test simulate v3" {
  run just simulate v3
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Link to Tenderly sim: $SIM_URL_V3" ]
}

@test "Test sign v2 clabs" {
  TEST_PK=$TEST_PK run just sign v2 clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_V2" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_CLABS_V2" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_CLABS_V2" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
}

@test "Test sign v3 clabs" {
  TEST_PK=$TEST_PK run just sign v3 clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v3" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_V3" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_CLABS_V3" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_CLABS_V3" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign v2 council" {
  TEST_PK=$TEST_PK run just sign v2 council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_V2" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V2" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_COUNCIL_V2" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign v3 council" {
  TEST_PK=$TEST_PK run just sign v3 council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v3" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_V3" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V3" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_COUNCIL_V3" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign with hd path" {
  TEST_PK=$TEST_PK run just sign v2 clabs "m/44'/52752'/1'/0/0"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
}

@test "Test sign v2 with grand child" {
  TEST_PK=$TEST_PK run just sign v2 council "" $GRAND_CHILD_MULTISIG 
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_V2" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V2" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_COUNCIL_V2" ]
  [ "${lines[5]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[7]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_V2" ]
  [ "${lines[8]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_V2" ]
  [ "${lines[9]}" = "Your account is $ACCOUNT" ]
  [ "${lines[10]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign v3 with grand child" {
  TEST_PK=$TEST_PK run just sign v3 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v3" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_V3" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V3" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_COUNCIL_V3" ]
  [ "${lines[5]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[7]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_V3" ]
  [ "${lines[8]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_V3" ]
  [ "${lines[9]}" = "Your account is $ACCOUNT" ]
  [ "${lines[10]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_ledger v2 clabs celo" {
  TEST_PK=$TEST_PK run just sign_ledger v2 clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
}

@test "Test sign_ledger v3 clabs celo" {
  TEST_PK=$TEST_PK run just sign_ledger v3 clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v3" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign_ledger v2 clabs eth" {
  TEST_PK=$TEST_PK run just sign_ledger v2 clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
}

@test "Test sign_ledger v3 clabs eth" {
  TEST_PK=$TEST_PK run just sign_ledger v3 clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v3" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign_ledger v2 council celo" {
  TEST_PK=$TEST_PK run just sign_ledger v2 council celo
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign_ledger v3 council celo" {
  TEST_PK=$TEST_PK run just sign_ledger v3 council celo
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v3" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_ledger v2 clabs base" {
  TEST_PK=$TEST_PK run just sign_ledger v2 clabs base
  [ "$status" -eq 1 ]
}

@test "Test sign_ledger celo with grand child" {
  TEST_PK=$TEST_PK run just sign_ledger v2 council celo "0" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[9]}" = "Your account is $ACCOUNT" ]
  [ "${lines[10]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign_ledger eth with grand child" {
  TEST_PK=$TEST_PK run just sign_ledger v2 council eth "0" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[9]}" = "Your account is $ACCOUNT" ]
  [ "${lines[10]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign_all clabs" {
  TEST_PK=$TEST_PK run just sign_all clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
  [ "${lines[8]}" = "Detected version: v3" ]
  [ "${lines[9]}" = "Detected team: clabs" ]
  [ "${lines[14]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign_all council" {
  TEST_PK=$TEST_PK run just sign_all council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V2" ]
  [ "${lines[8]}" = "Detected version: v3" ]
  [ "${lines[9]}" = "Detected team: council" ]
  [ "${lines[14]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_all with grand child" {
  TEST_PK=$TEST_PK run just sign_all council '' $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v2" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[10]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
  [ "${lines[12]}" = "Detected version: v3" ]
  [ "${lines[13]}" = "Detected team: council" ]
  [ "${lines[22]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_all_ledger clabs celo" {
  TEST_PK=$TEST_PK run just sign_all_ledger clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
  [ "${lines[10]}" = "Detected version: v3" ]
  [ "${lines[11]}" = "Detected team: clabs" ]
  [ "${lines[16]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign_all_ledger clabs eth" {
  TEST_PK=$TEST_PK run just sign_all_ledger clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
  [ "${lines[10]}" = "Detected version: v3" ]
  [ "${lines[11]}" = "Detected team: clabs" ]
  [ "${lines[16]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign_all_ledger council celo" {
  TEST_PK=$TEST_PK run just sign_all_ledger council celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V2" ]
  [ "${lines[10]}" = "Detected version: v3" ]
  [ "${lines[11]}" = "Detected team: council" ]
  [ "${lines[16]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_all_ledger council eth" {
  TEST_PK=$TEST_PK run just sign_all_ledger council eth
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V2" ]
  [ "${lines[10]}" = "Detected version: v3" ]
  [ "${lines[11]}" = "Detected team: council" ]
  [ "${lines[16]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_all_ledger celo with grand child" {
  TEST_PK=$TEST_PK run just sign_all_ledger council celo "0" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
  [ "${lines[14]}" = "Detected version: v3" ]
  [ "${lines[15]}" = "Detected team: council" ]
  [ "${lines[24]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_all_ledger eth with grand child" {
  TEST_PK=$TEST_PK run just sign_all_ledger council eth "0" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
  [ "${lines[14]}" = "Detected version: v3" ]
  [ "${lines[15]}" = "Detected team: council" ]
  [ "${lines[24]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V3" ]
}
