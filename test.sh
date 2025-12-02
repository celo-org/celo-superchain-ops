#!/usr/bin/env bats

# randomly generated empty address
TEST_PK=0xcf14463c272869f083e36ed4a221d3c0720a0288d813c33b90734dd3cde8d9b6

# constants
ACCOUNT=0xC2F43D252b2F3868061189F876EB215Cd78108f2
GRAND_CHILD_MULTISIG=0xD1C635987B6Aa287361d08C6461491Fa9df087f2
SIM_URL_V2="https://dashboard.tenderly.co/explorer/vnet/4c92d88c-598f-42fd-bfdc-c837b8d697cc/tx/0x7c44fe8c5c48931a322f0b986957c677b8871922ab152307e06f7319cd85f639"
SIM_URL_V3="https://dashboard.tenderly.co/explorer/vnet/4c92d88c-598f-42fd-bfdc-c837b8d697cc/tx/0x8d37735f7be725450d35187ea24f9050341a601817a2152c6fefa7a1192597da"
SIM_URL_SUCCINCT="https://dashboard.tenderly.co/explorer/vnet/053b540e-ae59-42c8-80a0-1250820dc894/tx/0x55742ec449b9659f3a5662c5b2f6d6a92d9d955a39eeaaeaf1df1726a3f2ff3f"
PARENT_HASH_V2=0xce6a4dc9ab7084ad8a53c87e6229860b09e8ad6ddd685eb9af1303fc28687966
PARENT_HASH_V3=0x7d2b307080c30634b946a54347349523ca40066f2538ae522edcee0c5ac3f20b
PARENT_HASH_SUCCINCT=0xf51bc03017739d768a7f1b9d8ba6ad81a5e89ae658b46f8fc6762216d36961ef

# clabs v2
CHILD_HASH_CLABS_V2=0x39e3d47f476221a6f535508ce18c758fa807e6f0bfe2b3ccd0db72dce7816f57
CHILD_DATA_CLABS_V2=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff47cdd52e02dbf2fa995bb9910a671110a6656d7490653b575f4ccf0a10ac4df7c
CHILD_SIG_CLABS_V2=10a74a6006d2b0ef570eca81f452241e1bf20ce5dff9435ea8b1ac8ca8a8e3e34684855bea946f6dfab841e993d0e7458ffd3e4a9c04f23baf0fe967a269453f1c

# clabs v3
CHILD_HASH_CLABS_V3=0x8fad1f02cc4fafd5d797cb3618d1f3133432a8e304a4c7467f231b0c62aa2c08
CHILD_DATA_CLABS_V3=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff4c32d0a231ed875321ab4ef97723dae474022483ca0c49c8acb318db05dff5a6c
CHILD_SIG_CLABS_V3=c4aaccd3bf3fecd12bb0741f0df679739a834023b4016acbd9566c51671eb7831b97a9c5ed654db3bdcd9fc35fd62ed9bd2cb55e54fb0158e4790fff23fea0031b

# council v2
CHILD_HASH_COUNCIL_V2=0x33c793d78ec78d906155c4ea671da7af5839c474877fcfcdddb9a99ed156f71a
CHILD_DATA_COUNCIL_V2=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239add5944f9671d0becd106c086bcce1aa9332b0fa3c8efd902c1e18c7d09b4b8bb8
CHILD_SIG_COUNCIL_V2=5c1a2b31a4e1233ca33b8e439926e18fc4d3cb671f2cb6d4e33743526ae7c8a60e3f5bd1d5c20f1c0b31a89fd0102a87f2a7d96d6e193728e4b8e07e3483797e1c

# council v3
CHILD_HASH_COUNCIL_V3=0xcee6d021cfab9130f615e539f726cb4c744a33f2060289a0b24ff47454a913f9
CHILD_DATA_COUNCIL_V3=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239add93ac87e17fdbd5eb4424b03a54b282e2f8ad094b8274cf9e2ab55abcf7a7e19
CHILD_SIG_COUNCIL_V3=46146bfbbe874b1f3ce51cc9ab04c69cfc370513f7e74b60b42092d0401bcf3e34b9946b4e2eb8c04d3c293e6c3d1ea47da0093236407750acb11636b2cb66ec1b

# grand child v2
GRAND_CHILD_HASH_COUNCIL_V2=0x59ec551278048342b9d36506edf6131217aa155ea0b8e52ecf888b73684d0261
GRAND_CHILD_DATA_COUNCIL_V2=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694fb1d59e9b790c47bc0236e8c74dd6751b2d695bb43503f3cfd7c0da3fdd68fc24
GRAND_CHILD_SIG_COUNCIL_V2=169b92418feb5704f152651cee96fa70117b4868ce12007c90b79dc487a267220f7ef14d35d1cddbc13c41171cf7611ca09233cbfd995ba3d49620bf482c715a1c

# grand child v3
GRAND_CHILD_HASH_COUNCIL_V3=0xf1b0f1eb3b1cb7c351b732c422c7db944fdb20f3f7f7f15188153636a24f79ad
GRAND_CHILD_DATA_COUNCIL_V3=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694f0798980f3feccc12bfe81c7b50fd3fc4eeaafd5dd8770047dc19028dce8b2940
GRAND_CHILD_SIG_COUNCIL_V3=85a8ee2366f626a5c72639b5f9ba612a1fa53cb7b8da3cc62ba82765077200257a7f21747ef171eec5bd0065d8c95a68a8c8d505eb8c7f2a744e0450bdf4a9b21c

# clabs succinct
CHILD_HASH_CLABS_SUCCINCT=0x9f4e59522154a98202b2aadba7e24c597a1bb8dec1b2a7ffe41c008104b72a74
CHILD_DATA_CLABS_SUCCINCT=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff4f4363a929eaca1f74fc33815b2ddd5324f24c7c0539bc8dcdbd6b996a4e1d5df
CHILD_SIG_CLABS_SUCCINCT=62cd770c6a8d31e4d7055b632cdd924375f777ed33dde24a7ce93d672fb2a07515707ca6f6c8652229af2e45bccbd3e35049aff9b151786afa7ee72fa6e7e7ff1b

# council succinct
CHILD_HASH_COUNCIL_SUCCINCT=0x8020b47b8edb20d2e6885425941c6ec69cd96470267e3fcb5bb45b7a025d916b
CHILD_DATA_COUNCIL_SUCCINCT=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239ada8150a2f410b1228be79a74beadac9e2be977c07eb690e574af4f02034e35833
CHILD_SIG_COUNCIL_SUCCINCT=ea9112c0ea32a0125d8690e03e865f2a9003c77c29e694e52b38e2cb4dcd2e6331f9216a975aec9ba2783d50fb6d595baba8b92e6576f7747464c7a58724f87f1c

# grand child succinct
GRAND_CHILD_HASH_COUNCIL_SUCCINCT=0xc3b663c7bf84571cfe00a32600f75be9f347af9ffbfbfcf49c3e15b5a76c1586
GRAND_CHILD_DATA_COUNCIL_SUCCINCT=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694fc54585eebce6808a53b241b75e3a870aec09315c01f608f38d1cd5925e71f62a
GRAND_CHILD_SIG_COUNCIL_SUCCINCT=f526e3076d986bf532bba89a2caecea8f103e56cec1526da6173de5bbf4750cd0b234929d984f2811ffc94b36b8119cc74e6b7f9d8e0191c41a19bc3c3d09d951b

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

@test "Test check-version succinct" {
  run just check-version succinct
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succinct" ]
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

@test "Test simulate succinct" {
  run just simulate succinct
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Link to Tenderly sim: $SIM_URL_SUCCINCT" ]
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

@test "Test sign succinct clabs" {
  TEST_PK=$TEST_PK run just sign succinct clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succinct" ]
  [ "${lines[1]}" = "Detected team: clabs" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_SUCCINCT" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_CLABS_SUCCINCT" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_CLABS_SUCCINCT" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_SUCCINCT" ]
}

@test "Test sign succinct council" {
  TEST_PK=$TEST_PK run just sign succinct council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succinct" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_SUCCINCT" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCCINCT" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCCINCT" ]
  [ "${lines[5]}" = "Your account is $ACCOUNT" ]
  [ "${lines[6]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_SUCCINCT" ]
}

@test "Test sign succinct council with grand child" {
  TEST_PK=$TEST_PK run just sign succinct council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succinct" ]
  [ "${lines[1]}" = "Detected team: council" ]
  [ "${lines[2]}" = "Parent tx hash: $PARENT_HASH_SUCCINCT" ]
  [ "${lines[3]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCCINCT" ]
  [ "${lines[4]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCCINCT" ]
  [ "${lines[5]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[7]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_SUCCINCT" ]
  [ "${lines[8]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_SUCCINCT" ]
  [ "${lines[9]}" = "Your account is $ACCOUNT" ]
  [ "${lines[10]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_SUCCINCT" ]
}
