#!/usr/bin/env bats

# randomly generated empty address
TEST_PK=0xcf14463c272869f083e36ed4a221d3c0720a0288d813c33b90734dd3cde8d9b6

# constants
ACCOUNT=0xC2F43D252b2F3868061189F876EB215Cd78108f2
GRAND_CHILD_MULTISIG=0xD1C635987B6Aa287361d08C6461491Fa9df087f2
SIM_URL_SUCC_V1="https://dashboard.tenderly.co/explorer/vnet/053b540e-ae59-42c8-80a0-1250820dc894/tx/0x55742ec449b9659f3a5662c5b2f6d6a92d9d955a39eeaaeaf1df1726a3f2ff3f"
SIM_URL_SUCC_V102="https://dashboard.tenderly.co/explorer/vnet/39498d1a-4638-47d3-8bbc-010de8f718ce/tx/0x27f7a467c7d7faa3aa9934ffc2810a4d910e2404783aed427a5fa1f732f7e12d"
SIM_URL_V4="https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0x962ef321746bb075a44226bdd645b469e761fb7dbdeb42869902b6e7ebc3b7ef"
SIM_URL_V5="https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0x833bca6071ad1cf1c82acbb58fccefe75e06978454431c0597819cb743363bbb"
SIM_URL_SUCC_V2="https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0xce7dc169f6885f8ca937135a562068e3444e6c7fc299ffb7e2341372ed006dda"
PARENT_HASH_V2=0xce6a4dc9ab7084ad8a53c87e6229860b09e8ad6ddd685eb9af1303fc28687966
PARENT_HASH_V3=0x7d2b307080c30634b946a54347349523ca40066f2538ae522edcee0c5ac3f20b
PARENT_HASH_SUCC_V1=0xf51bc03017739d768a7f1b9d8ba6ad81a5e89ae658b46f8fc6762216d36961ef
PARENT_HASH_SUCC_V102=0xa17db5fb2aa052b03a49ed701483f37fa9e795b7ccbbe6f19905af99e358a54f

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
GRAND_CHILD_HASH_COUNCIL_V2=0xcca7d91e9075bc6d17e8ce373ce7dd2c90a72c312ade08bb4721eb806694c266
GRAND_CHILD_DATA_COUNCIL_V2=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694fc761885f1dd5fa4d63b9f47abf37859ec8ecbf42e3d6c0f0c6bfd1d55c21fe03
GRAND_CHILD_SIG_COUNCIL_V2=d63bd3aa5bafa79fa31db8f97e418fb7c5ee539b71e7dc1c05216a33c44a97ab36e247758c4536207dd7ee8f6f59623ac4244174fa8af806ae6c1d1e683f3aa21b

# grand child v3
GRAND_CHILD_HASH_COUNCIL_V3=0xe93df30445c94da41b10137365b98a90f6060b1cf8e487378df7757e5632635b
GRAND_CHILD_DATA_COUNCIL_V3=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694fb1cdb6042f77a4c58321e211ac3aa9d58e1f69643a7e642175459d5df7bc3069
GRAND_CHILD_SIG_COUNCIL_V3=f550545304eed51d755da995bf1b21a38a8597bf8ce252101ce62f5ad50e20b94f7d2be3d91252f291790c92fd6e8fabc012b533ea235ab7cd8754d8169a1d081c

# clabs succ-v1
CHILD_HASH_CLABS_SUCC_V1=0x9f4e59522154a98202b2aadba7e24c597a1bb8dec1b2a7ffe41c008104b72a74
CHILD_DATA_CLABS_SUCC_V1=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff4f4363a929eaca1f74fc33815b2ddd5324f24c7c0539bc8dcdbd6b996a4e1d5df
CHILD_SIG_CLABS_SUCC_V1=62cd770c6a8d31e4d7055b632cdd924375f777ed33dde24a7ce93d672fb2a07515707ca6f6c8652229af2e45bccbd3e35049aff9b151786afa7ee72fa6e7e7ff1b

# council succ-v1
CHILD_HASH_COUNCIL_SUCC_V1=0x8020b47b8edb20d2e6885425941c6ec69cd96470267e3fcb5bb45b7a025d916b
CHILD_DATA_COUNCIL_SUCC_V1=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239ada8150a2f410b1228be79a74beadac9e2be977c07eb690e574af4f02034e35833
CHILD_SIG_COUNCIL_SUCC_V1=ea9112c0ea32a0125d8690e03e865f2a9003c77c29e694e52b38e2cb4dcd2e6331f9216a975aec9ba2783d50fb6d595baba8b92e6576f7747464c7a58724f87f1c

# grand child succ-v1
GRAND_CHILD_HASH_COUNCIL_SUCC_V1=0xc3b663c7bf84571cfe00a32600f75be9f347af9ffbfbfcf49c3e15b5a76c1586
GRAND_CHILD_DATA_COUNCIL_SUCC_V1=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694fc54585eebce6808a53b241b75e3a870aec09315c01f608f38d1cd5925e71f62a
GRAND_CHILD_SIG_COUNCIL_SUCC_V1=f526e3076d986bf532bba89a2caecea8f103e56cec1526da6173de5bbf4750cd0b234929d984f2811ffc94b36b8119cc74e6b7f9d8e0191c41a19bc3c3d09d951b

# clabs succ-v102
CHILD_HASH_CLABS_SUCC_V102=0x192686d012b9fb971127d9307e6aa72a632f9e6734225cb0b3f19c0b1c1db3ad
CHILD_DATA_CLABS_SUCC_V102=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff458fd5e099c3626394e57669d86be6989ddec52aee4a438d81263aef29eda20f3
CHILD_SIG_CLABS_SUCC_V102=a5b9ebac016e3016c6f0d8e0d33f726abed4dacb2a392f13251ef2b9e36b7a157bb1a531788e8c6b02a1a0ce4abd48ebc613d5a034a99bccdb5eccf6d62cf1fb1b

# council succ-v102
CHILD_HASH_COUNCIL_SUCC_V102=0xb249f86c808e56add978b80a312200ab5895ae770bef40267bb98e624c6e568e
CHILD_DATA_COUNCIL_SUCC_V102=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239ad4b66909b1322535195b6fd334364a7b5fe1833cd4ceba233e2c9f5767758d2bb
CHILD_SIG_COUNCIL_SUCC_V102=d52015a492b61deca237917b5462aa76bffc1064297779f243c6bb3d6c74b278528c010f52e0e2cfcd0b9227d04e51083b2780892ffd301351a4e507111b45da1c

# grand child succ-v102
GRAND_CHILD_HASH_COUNCIL_SUCC_V102=0xf55fb48d534eaf441b0b1941e742cc235a12abacec57e3330edfa759e7c9d06d
GRAND_CHILD_DATA_COUNCIL_SUCC_V102=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694f8040306269cbf1b624ba5f3c352a9e883dbe01ac3fb714da2bc8a96e0c4e131f
GRAND_CHILD_SIG_COUNCIL_SUCC_V102=e6832e2ee6d31c3bf6891a12787c6ba41df73008616590ab08474f6aac6e188535227a07f907b783e8a763fb0dbafdc63bff0f5b6c6775cc357fc03bef61c67b1c

# TODO: v4 - populate after calldata is finalized
PARENT_HASH_V4=TODO
CHILD_HASH_CLABS_V4=TODO
CHILD_DATA_CLABS_V4=TODO
CHILD_SIG_CLABS_V4=TODO
CHILD_HASH_COUNCIL_V4=TODO
CHILD_DATA_COUNCIL_V4=TODO
CHILD_SIG_COUNCIL_V4=TODO
GRAND_CHILD_HASH_COUNCIL_V4=TODO
GRAND_CHILD_DATA_COUNCIL_V4=TODO
GRAND_CHILD_SIG_COUNCIL_V4=TODO

# TODO: v5 - populate after calldata is finalized
PARENT_HASH_V5=TODO
CHILD_HASH_CLABS_V5=TODO
CHILD_DATA_CLABS_V5=TODO
CHILD_SIG_CLABS_V5=TODO
CHILD_HASH_COUNCIL_V5=TODO
CHILD_DATA_COUNCIL_V5=TODO
CHILD_SIG_COUNCIL_V5=TODO
GRAND_CHILD_HASH_COUNCIL_V5=TODO
GRAND_CHILD_DATA_COUNCIL_V5=TODO
GRAND_CHILD_SIG_COUNCIL_V5=TODO

# TODO: succ-v2 - populate after calldata is finalized
PARENT_HASH_SUCC_V2=TODO
CHILD_HASH_CLABS_SUCC_V2=TODO
CHILD_DATA_CLABS_SUCC_V2=TODO
CHILD_SIG_CLABS_SUCC_V2=TODO
CHILD_HASH_COUNCIL_SUCC_V2=TODO
CHILD_DATA_COUNCIL_SUCC_V2=TODO
CHILD_SIG_COUNCIL_SUCC_V2=TODO
GRAND_CHILD_HASH_COUNCIL_SUCC_V2=TODO
GRAND_CHILD_DATA_COUNCIL_SUCC_V2=TODO
GRAND_CHILD_SIG_COUNCIL_SUCC_V2=TODO

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

@test "Test check-version succ-v1" {
  run just check-version succ-v1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succ-v1" ]
}

@test "Test check-version succ-v102" {
  run just check-version succ-v102
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succ-v102" ]
}

@test "Test check-version v4" {
  run just check-version v4
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v4" ]
}

@test "Test check-version v5" {
  run just check-version v5
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: v5" ]
}

@test "Test check-version succ-v2" {
  run just check-version succ-v2
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succ-v2" ]
}

@test "Test check-version v99" {
  run just check-version v99
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Invalid version: v99" ]
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

@test "Test check-network mainnet" {
  run just check-network mainnet
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: mainnet" ]
}

@test "Test check-network sepolia" {
  run just check-network sepolia
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
}

@test "Test check-network invalid" {
  run just check-network goerli
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Invalid network: goerli" ]
}

@test "Test mainnet upgrade files exist" {
  [ -f "upgrades/mainnet/01-v2.json" ]
  [ -f "upgrades/mainnet/02-v3.json" ]
  [ -f "upgrades/mainnet/03-succ-v1.json" ]
  [ -f "upgrades/mainnet/04-succ-v102.json" ]
  [ -f "upgrades/mainnet/05-v4.json" ]
  [ -f "upgrades/mainnet/06-v5.json" ]
  [ -f "upgrades/mainnet/07-succ-v2.json" ]
}

@test "Test sepolia upgrade files exist" {
  [ -f "upgrades/sepolia/01-v4.json" ]
  [ -f "upgrades/sepolia/02-v5.json" ]
  [ -f "upgrades/sepolia/03-succ-v2.json" ]
}

@test "Test mainnet address files exist" {
  [ -f "addresses/mainnet/01-v2.json" ]
  [ -f "addresses/mainnet/02-v3.json" ]
  [ -f "addresses/mainnet/03-succ-v1.json" ]
  [ -f "addresses/mainnet/04-succ-v102.json" ]
  [ -f "addresses/mainnet/05-v4.json" ]
  [ -f "addresses/mainnet/06-v5.json" ]
  [ -f "addresses/mainnet/07-succ-v2.json" ]
}

@test "Test sepolia address files exist" {
  [ -f "addresses/sepolia/01-v4.json" ]
  [ -f "addresses/sepolia/02-v5.json" ]
  [ -f "addresses/sepolia/03-succ-v2.json" ]
}

@test "Test simulate v2" {
  run just simulate v2
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "Simulation URL inactive for mainnet/v2" ]
}

@test "Test simulate v3" {
  run just simulate v3
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "Simulation URL inactive for mainnet/v3" ]
}

@test "Test simulate succ-v1" {
  run just simulate succ-v1
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "succ-v1: $SIM_URL_SUCC_V1" ]
}

@test "Test simulate succ-v102" {
  run just simulate succ-v102
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "succ-v102: $SIM_URL_SUCC_V102" ]
}

@test "Test simulate v4" {
  run just simulate v4
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "v4: $SIM_URL_V4" ]
}

@test "Test simulate v5" {
  run just simulate v5
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "v5: $SIM_URL_V5" ]
}

@test "Test simulate succ-v2" {
  run just simulate succ-v2
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "succ-v2: $SIM_URL_SUCC_V2" ]
}

@test "Test sign v2 clabs" {
  TEST_PK=$TEST_PK run just sign v2 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V2" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_V2" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_V2" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
}

@test "Test sign v3 clabs" {
  TEST_PK=$TEST_PK run just sign v3 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v3" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V3" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_V3" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_V3" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign v2 council" {
  TEST_PK=$TEST_PK run just sign v2 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V2" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V2" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_V2" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign v3 council" {
  TEST_PK=$TEST_PK run just sign v3 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v3" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V3" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V3" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_V3" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign with hd path" {
  TEST_PK=$TEST_PK run just sign v2 clabs "m/44'/52752'/1'/0/0"
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
}

@test "Test sign v2 with grand child" {
  TEST_PK=$TEST_PK run just sign v2 council "" $GRAND_CHILD_MULTISIG 
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V2" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V2" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_V2" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_V2" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_V2" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign v3 with grand child" {
  TEST_PK=$TEST_PK run just sign v3 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v3" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V3" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V3" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_V3" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_V3" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_V3" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_ledger v2 clabs celo" {
  TEST_PK=$TEST_PK run just sign_ledger v2 clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
}

@test "Test sign_ledger v3 clabs celo" {
  TEST_PK=$TEST_PK run just sign_ledger v3 clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v3" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign_ledger v2 clabs eth" {
  TEST_PK=$TEST_PK run just sign_ledger v2 clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V2" ]
}

@test "Test sign_ledger v3 clabs eth" {
  TEST_PK=$TEST_PK run just sign_ledger v3 clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v3" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V3" ]
}

@test "Test sign_ledger v2 council celo" {
  TEST_PK=$TEST_PK run just sign_ledger v2 council celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign_ledger v3 council celo" {
  TEST_PK=$TEST_PK run just sign_ledger v3 council celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v3" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V3" ]
}

@test "Test sign_ledger v2 clabs base" {
  TEST_PK=$TEST_PK run just sign_ledger v2 clabs base
  [ "$status" -eq 1 ]
}

@test "Test sign_ledger celo with grand child" {
  TEST_PK=$TEST_PK run just sign_ledger v2 council celo "0" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign_ledger eth with grand child" {
  TEST_PK=$TEST_PK run just sign_ledger v2 council eth "0" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V2" ]
}

@test "Test sign succ-v1 clabs" {
  TEST_PK=$TEST_PK run just sign succ-v1 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v1" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V1" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_SUCC_V1" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_SUCC_V1" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_SUCC_V1" ]
}

@test "Test sign succ-v1 council" {
  TEST_PK=$TEST_PK run just sign succ-v1 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v1" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V1" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCC_V1" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCC_V1" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_SUCC_V1" ]
}

@test "Test sign succ-v1 council with grand child" {
  TEST_PK=$TEST_PK run just sign succ-v1 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v1" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V1" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCC_V1" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCC_V1" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_SUCC_V1" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_SUCC_V1" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_SUCC_V1" ]
}

@test "Test sign succ-v102 clabs" {
  TEST_PK=$TEST_PK run just sign succ-v102 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v102" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V102" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_SUCC_V102" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_SUCC_V102" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_SUCC_V102" ]
}

@test "Test sign succ-v102 council" {
  TEST_PK=$TEST_PK run just sign succ-v102 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v102" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V102" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCC_V102" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCC_V102" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_SUCC_V102" ]
}

@test "Test sign succ-v102 council with grand child" {
  TEST_PK=$TEST_PK run just sign succ-v102 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v102" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V102" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCC_V102" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCC_V102" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_SUCC_V102" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_SUCC_V102" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_SUCC_V102" ]
}

# --- v4 sign tests (TODO: populate expected values) ---

@test "Test sign v4 clabs" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign v4 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V4" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_V4" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_V4" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V4" ]
}

@test "Test sign v4 council" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign v4 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V4" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V4" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_V4" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V4" ]
}

@test "Test sign v4 council with grand child" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign v4 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V4" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V4" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_V4" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_V4" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_V4" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V4" ]
}

@test "Test sign_ledger v4 clabs celo" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign_ledger v4 clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V4" ]
}

@test "Test sign_ledger v4 clabs eth" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign_ledger v4 clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V4" ]
}

@test "Test sign_ledger v4 council celo" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign_ledger v4 council celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V4" ]
}

# --- v5 sign tests (TODO: populate expected values) ---

@test "Test sign v5 clabs" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign v5 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V5" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_V5" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_V5" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V5" ]
}

@test "Test sign v5 council" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign v5 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V5" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V5" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_V5" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V5" ]
}

@test "Test sign v5 council with grand child" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign v5 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_V5" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_V5" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_V5" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_V5" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_V5" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_V5" ]
}

@test "Test sign_ledger v5 clabs celo" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign_ledger v5 clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V5" ]
}

@test "Test sign_ledger v5 clabs eth" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign_ledger v5 clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V5" ]
}

@test "Test sign_ledger v5 council celo" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign_ledger v5 council celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V5" ]
}

# --- succ-v2 sign tests (TODO: populate expected values) ---

@test "Test sign succ-v2 clabs" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign succ-v2 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v2" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V2" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_SUCC_V2" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_SUCC_V2" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_SUCC_V2" ]
}

@test "Test sign succ-v2 council" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign succ-v2 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V2" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCC_V2" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCC_V2" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_SUCC_V2" ]
}

@test "Test sign succ-v2 council with grand child" {
  skip "TODO: populate expected values in test constants"
  TEST_PK=$TEST_PK run just sign succ-v2 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V2" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCC_V2" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCC_V2" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_SUCC_V2" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_SUCC_V2" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_SUCC_V2" ]
}

# --- sepolia sign tests (TODO: populate after sepolia Safe deployment) ---

@test "Test sign v4 clabs on sepolia" {
  skip "TODO: populate sepolia upgrade calldata and expected values"
}

@test "Test sign v4 council on sepolia" {
  skip "TODO: populate sepolia upgrade calldata and expected values"
}

@test "Test sign v5 clabs on sepolia" {
  skip "TODO: populate sepolia upgrade calldata and expected values"
}

@test "Test sign v5 council on sepolia" {
  skip "TODO: populate sepolia upgrade calldata and expected values"
}

@test "Test sign succ-v2 clabs on sepolia" {
  skip "TODO: populate sepolia upgrade calldata and expected values"
}

@test "Test sign succ-v2 council on sepolia" {
  skip "TODO: populate sepolia upgrade calldata and expected values"
}
