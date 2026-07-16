#!/usr/bin/env bats

# randomly generated empty address
TEST_PK=0xcf14463c272869f083e36ed4a221d3c0720a0288d813c33b90734dd3cde8d9b6

# constants
ACCOUNT=0xC2F43D252b2F3868061189F876EB215Cd78108f2
GRAND_CHILD_MULTISIG=0xD1C635987B6Aa287361d08C6461491Fa9df087f2
SIM_URL_V4="https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0x962ef321746bb075a44226bdd645b469e761fb7dbdeb42869902b6e7ebc3b7ef"
SIM_URL_V5="https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0x833bca6071ad1cf1c82acbb58fccefe75e06978454431c0597819cb743363bbb"
SIM_URL_SUCC_V2="https://dashboard.tenderly.co/explorer/vnet/1baaac03-3928-48a7-99b6-2fdf0b2add6d/tx/0xce7dc169f6885f8ca937135a562068e3444e6c7fc299ffb7e2341372ed006dda"
SIM_URL_SUCC_V201="https://dashboard.tenderly.co/explorer/vnet/6044ea35-ad95-4d0c-8440-135ccb38ba95/tx/0x0b1d4c6376df347fc937439862c65aebaa4dcb693ed785e3202f1591a4c88bcf"
SIM_URL_SUCC_V210="https://dashboard.tenderly.co/explorer/vnet/7682d855-f265-40df-abe0-b3b829eb824a/tx/0x96891cb8e0f89e77228ae0ca53ca4cf9c97c9bb162615eb11b506de1644734e4"
SIM_URL_EIGENDA_CERT_V3="https://dashboard.tenderly.co/explorer/vnet/7f58af78-e2ba-4ef2-8cd1-6dd329723aee/tx/0x2792faf8a438323dfd76844ef9f5d6b346c677fbf1951430cb458883073c6fd7"
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

# mainnet v4
PARENT_HASH_V4=0xe7dd2f018e5ab62df31a1cc0c102b829a872f8a85e032f1bc635878f9e7ef3ae
CHILD_HASH_CLABS_V4=0xeb29110d67b6a92efbcff0d75eeb07d4291bcde69972483a79ce8590f90d1a79
CHILD_DATA_CLABS_V4=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff4a351fb3d5520affa1732afb50a173c026726529416f4d492ead46449067c0dbc
CHILD_SIG_CLABS_V4=31960ec49fcd97527b68f56e553dd6d31bb1e8c058c509ea125a9e2a0703281271fe805e4cf7d99f636f658522ea40bfc9a0c3d3f921130cad93beccd32815e61b
CHILD_HASH_COUNCIL_V4=0x44ec89171bad653c4668ec651d523c5a030651bc916f18f5317f9e1e514dbcc9
CHILD_DATA_COUNCIL_V4=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239ad2cc4a924638f66c0f3cb1b117440f0a538b09b993a8436352b6bd7beb7f2a692
CHILD_SIG_COUNCIL_V4=31ffe59c8965568d3528df36104c72dd1bbbdec60e71c76ffdfbd81d021b65d75159a982da7ec1148bf597b406559e95db59e59fcebe9a1446a4a6cb5610b9881b
GRAND_CHILD_HASH_COUNCIL_V4=0x2c11da2ae980fcffb3746c85fa74e4a346379ca37064a88f1e71fb7d91edb02a
GRAND_CHILD_DATA_COUNCIL_V4=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694f9a90909b6558af93ba481bca490cd955cf01168fdd0018983c476e16e9201c8c
GRAND_CHILD_SIG_COUNCIL_V4=0c92c8d65fcafd3688cc01bfcfeb5d6ed94fe1fc870dbda4061903bf8745bbbd0f44ecd96119f9392f3b3b3f423acc56460cb0d499995e90addc4b5fd4ae7ef51b

# mainnet v5
PARENT_HASH_V5=0x4ec4658f345c5f9a767a24ce5963903534cda8385ba208347fffa84ea6b60372
CHILD_HASH_CLABS_V5=0x45ed492b9418637703c60b80a62ac195f9292d5ae5e43158d90127c6ae141ab4
CHILD_DATA_CLABS_V5=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff4c9cd5b7157f288304a16b1895492a23b8c0fe23692bec0924ec6a0e594d9b273
CHILD_SIG_CLABS_V5=4f15f3db6b17f7be3774283501da70e276c5114053c9a23e862e62ea2952c2531bde7e99f9f923a90cac620a48ee78d051c386f810799239467cb6b7c7a1a5121c
CHILD_HASH_COUNCIL_V5=0x37e3f4c413e01d24c70688f4d1c88cf99b8f34dd8c8a11b6aafc11a01fb3a724
CHILD_DATA_COUNCIL_V5=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239ad6c25ee01a09badcf6130b27368ac1465d182cf7f7abf4f500358eb3d57b965be
CHILD_SIG_COUNCIL_V5=3c273aac627294a377510cb018e265a5055a89cfebae741037994c65dd822413315b4cec69e1809e3a8f9b89bf4f6b263c4481a8d8b0cf33ef4c436af54f15f71c
GRAND_CHILD_HASH_COUNCIL_V5=0x3c474fb15bcacd725c2ea002034d2ee0c509d0ebbfe2fd294dc0dd1aaf0b2bce
GRAND_CHILD_DATA_COUNCIL_V5=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694fa845df950524230a108f0bfe7d376bf90767eaba1d93d23d6c292952ddf6c8c2
GRAND_CHILD_SIG_COUNCIL_V5=f035ee3b6bfefe7db91611d2c7d815ab0c320fb916cb3dac8ac4582326bd054516f9fc539921b2779429796454737ed9d32a53ad966112f37697bd1e589a50ef1c

# mainnet succ-v210
PARENT_HASH_SUCC_V210=0xb9764747865fc50d1e9ee3ef2bbcd6b31819a116f249c79c76e485b3425d8603
CHILD_HASH_CLABS_SUCC_V210=0x555e055d2d028f797edb4c237f06c160ae88377653677c7aec80fa9738485a04
CHILD_DATA_CLABS_SUCC_V210=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff4334f86d22c6199e07be12e4b9b19b83bae5785618b1fb35eb63fef12c6809166
CHILD_SIG_CLABS_SUCC_V210=41357fb5faef41ec0f1fd15b3951ebfcd74bc9363bfffcd2fa8106ff125a35757ddb7b1514ecf0f065afad568fecf61b94ef00aacbb2d61e32b465c214f890941c
CHILD_HASH_COUNCIL_SUCC_V210=0xfff6133825fc191f2a227e834961f36ee19e212d1f3752032710b45b91814ab2
CHILD_DATA_COUNCIL_SUCC_V210=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239adc1a953ec40354715dd654725d33ed135f0dc2cda1e8f43c97167d15079ef8fe9
CHILD_SIG_COUNCIL_SUCC_V210=141f57ddd41a9d2554797fe3745a2db1d1ac5ff62267cb4f4e32e4c18535ec7b7e1200b642719431b05a6bc5706565610df744d70e59cf8acffee748324768f51b
GRAND_CHILD_HASH_COUNCIL_SUCC_V210=0x469f006cb90b3a0a361a76209477e22f8e7c3b8effc32e4d90fddeb3aa56dab0
GRAND_CHILD_DATA_COUNCIL_SUCC_V210=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694f36b02223dc4e738d1e031c8eb30363156e0a6ab8f0d1545db701adc928073fbe
GRAND_CHILD_SIG_COUNCIL_SUCC_V210=5ce0af68fcc05ae3062d74172af7421858502d2dd724d7fbdb3dce2d83d41f6b49927604d43d7f3b9bb14837c55233d5be648f7aa641c024385cdfebf50a58bf1c

# mainnet succ-v2
PARENT_HASH_SUCC_V2=0xb87fa55e7ec055bb6b4a4a2b4f46c30e671a3b41510e9b83b4e76dda427561e7
CHILD_HASH_CLABS_SUCC_V2=0x37645c36dfd556412f0e7ea4568851534d4b85ebbea50c16057d48ea1be25a1b
CHILD_DATA_CLABS_SUCC_V2=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff4d2164f66cc364ac0d435efccf45a4505cace5cf2a5c715f1b3a26abe81473694
CHILD_SIG_CLABS_SUCC_V2=c59e5752d7b92af6395da5fc022996f81fc1fe52273ec78a38059e04959b5ace2d445b165c7d0a47a11f96a13410e1511c2e842cad89a5e7ebf9fa8593a54c4b1c
CHILD_HASH_COUNCIL_SUCC_V2=0xe3619f852be1c3e7b8030cb7ff2ea613bead17d179e4428dc7995c59f42fe01f
CHILD_DATA_COUNCIL_SUCC_V2=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239ad8b8000a59fc46a8dc228a0578a2df4da0c8d1f38d0a39c6a96e3a35d8c17f6a4
CHILD_SIG_COUNCIL_SUCC_V2=387e5c108a02cb8fadca32bb3166843fae1acffc2d717d7e82da575ded020d9002ea106b1ffd198eea94bd44f7a7306a7415f6190177106daf4f2e1a0c54d3d51c
GRAND_CHILD_HASH_COUNCIL_SUCC_V2=0x68125bdde5167d54aef14258aab83c9ce5c4c3ec2120fcd4c09c13f857c00285
GRAND_CHILD_DATA_COUNCIL_SUCC_V2=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694f5c3409dad16d68b98628d09be3ae4cb87b20ebfb51b79dbffc0176183886c40c
GRAND_CHILD_SIG_COUNCIL_SUCC_V2=18b9986fb67b9159ef4c144c9d0ab7b71ad4b0c1195d2c8be17a229410cfce890fd6ef84708e4cc979411c9f2abf8d8cd0209832899dc999c7e7d99e12c7f06f1c

# mainnet eigenda-cert-v3
PARENT_HASH_EIGENDA_CERT_V3=0xdd089411bde8718db3604002098f9b461a0e26348a2af47b9c761af91f2e2b52
CHILD_HASH_CLABS_EIGENDA_CERT_V3=0x21c05a0a232988770d4a59fdbb810dbf684bc0fe471c0f82ffae7087a8a53f23
CHILD_DATA_CLABS_EIGENDA_CERT_V3=0x1901c7a8fb49e5d601acc381538cdace161d64d5f25a93261cded88243db64e1cff4b8ed2622cb3ee8e7684617e5c82fc6f87faa5f2f56f3d8050b03ab4a6280391c
CHILD_SIG_CLABS_EIGENDA_CERT_V3=6bf4f52a95dba2deda9e080b0f58ea636ba089f12aa378d5c847ff01d5d295560f59a4eb3c913e407b5f6e68c6454d93582fa1551b16f9645f20aa00864a9edf1b
CHILD_HASH_COUNCIL_EIGENDA_CERT_V3=0x6ffa3c9e901ab99600aece3473f83efce8003bee6459cc07f04d8c51c77610c9
CHILD_DATA_COUNCIL_EIGENDA_CERT_V3=0x1901006bcc13a9a6b3224caf34092bd0db63b90656971bfec6731c9c61f278a239ad1703bf04624d03b15c51661d420fd9add4a84401bac88aceb228861ffb37a661
CHILD_SIG_COUNCIL_EIGENDA_CERT_V3=cee835f528618270a67a691490776bc98d64d6f9db5f7c2795d16cc0a6a619586b04a8a109e3e6599d72ff4559280ba0b69a6933bacc20d70c65bd15e78acece1b
GRAND_CHILD_HASH_COUNCIL_EIGENDA_CERT_V3=0x534d853589d4a115294ed7a0d8da1f68821f70589dd163f3948bc06c3eb3ef39
GRAND_CHILD_DATA_COUNCIL_EIGENDA_CERT_V3=0x1901b889fe0bca2c1159d0891cdc881184aad05e5f55c5cf93ef3be10360d179694f1f3990505570a22595d4a4c496fef4ff67a4c5c72393a3a03ae35890d07908ea
GRAND_CHILD_SIG_COUNCIL_EIGENDA_CERT_V3=e4f4866823ff31b73b4d6c6746e466c053f303af27a6d812336e024eabe333222c50a46c7e09189eb51b06a77d1a74c5c894d040ece30e6497b193071ae804121b

# sepolia v4
SEPOLIA_PARENT_HASH_V4=0x5596eeb4559143b00bf03d5bc3c9865b8d79f0eb524ea95d2e19f4a38c56d63a
SEPOLIA_CHILD_HASH_CLABS_V4=0x277254b44d20055d7fdc01d3daceb616e043ce32e7f4d87f2bebb2ab7e79a8ec
SEPOLIA_CHILD_DATA_CLABS_V4=0x19010997447f88a2bb698764da0831cf77290b5f52333cf06515d7c747a213b37add7755091a1efc158ab154b006fa089af6016de41e13b987eb1903e41b8dc2228b
SEPOLIA_CHILD_SIG_CLABS_V4=c9c9784fc2914d2b614dca755c55b17a0515511c2f53852fd9619772d5335c3f3909409568a9fcd2d0a58dad045ff24610d5f5f1e8c858ad48eb845e322407d51b
SEPOLIA_CHILD_HASH_COUNCIL_V4=0xdd92ba01d36bfa15bba3e2da8d01c34bd857e458cc986a6fc8bda84c138d8fb1
SEPOLIA_CHILD_DATA_COUNCIL_V4=0x1901cd00dbdd235174967fdd794795e947ae94fb2433442e6f497cbcb8ade286c3ff7755091a1efc158ab154b006fa089af6016de41e13b987eb1903e41b8dc2228b
SEPOLIA_CHILD_SIG_COUNCIL_V4=8f3f606053fa554dfbe5f0ac52b933db194094b9cdc6951a21d5b460eae09d1d34b8c72b2f210e5cb2b10dbeb07dc56d8491dffb2b2fcffc684382cb658bf2481c

# sepolia v5
SEPOLIA_PARENT_HASH_V5=0xfb9a4ff006153396dd05481ce534a5112a866bd2d8044e9c99fc6ead5457efd4
SEPOLIA_CHILD_HASH_CLABS_V5=0xc5972b23f22e702a0149a6739f2ea304add2ef18f4b68171ba55c0e058d2e070
SEPOLIA_CHILD_DATA_CLABS_V5=0x19010997447f88a2bb698764da0831cf77290b5f52333cf06515d7c747a213b37add594634563c3dc06fe228833f5d9cab98af19a1502285336450b6c925049d526e
SEPOLIA_CHILD_SIG_CLABS_V5=1cc82d963eb3308bf51f6d4bc19153c3a60c81c7aa4cc5818e94d6dc0f2a1e1d31aa91db3c62c619a8cf22450fcc47bebc3ed8b837dec577f48ac510245c3cb71b
SEPOLIA_CHILD_HASH_COUNCIL_V5=0x037b932d690879e954911a573a05a9011d046a7bd04772a765f7ef63cadb9a02
SEPOLIA_CHILD_DATA_COUNCIL_V5=0x1901cd00dbdd235174967fdd794795e947ae94fb2433442e6f497cbcb8ade286c3ff594634563c3dc06fe228833f5d9cab98af19a1502285336450b6c925049d526e
SEPOLIA_CHILD_SIG_COUNCIL_V5=865b27782d36a13c2fa481d549ad18d2d31c93d5ee0f4a0a34d43994881099544d61b7af2a3ef54c923271a0547b58e9d72f815bb9a3ec2596f89811dc3a1f971b

# sepolia succ-v2
SEPOLIA_PARENT_HASH_SUCC_V2=0xc44dab38d4befca24b2f1fdc0fa0acd6426aae34699cd1fe53b973de786d2348
SEPOLIA_CHILD_HASH_CLABS_SUCC_V2=0x0d1f7f43cc5719765f2af830a4e149de10f8176878795310d52d3c8d9ffeb56f
SEPOLIA_CHILD_DATA_CLABS_SUCC_V2=0x19010997447f88a2bb698764da0831cf77290b5f52333cf06515d7c747a213b37addf3167c00a8d1eb314153239227692d662ab3d47c0c8526a75200c0d1636e4449
SEPOLIA_CHILD_SIG_CLABS_SUCC_V2=caac3918e752aa8d50deeda1011ecbbca9d0e0deb59467ebd4c1d91d4085afaf55f0b4f4c0df8ffa76a4dbfc3fa4c16a1a0c94390840148457e5c71238a5f0881c
SEPOLIA_CHILD_HASH_COUNCIL_SUCC_V2=0xdd73251c3f75d83cd0f51a80da35d9f03bb1d2a56f48d3693aac7fae75598d8a
SEPOLIA_CHILD_DATA_COUNCIL_SUCC_V2=0x1901cd00dbdd235174967fdd794795e947ae94fb2433442e6f497cbcb8ade286c3fff3167c00a8d1eb314153239227692d662ab3d47c0c8526a75200c0d1636e4449
SEPOLIA_CHILD_SIG_COUNCIL_SUCC_V2=c6fbc1f19097efdfef5f10e67e5bd124f7218becfb0b571612f0b6230fee59aa72d9d5cbbd3878be82a3a5a719291bbd3ae043ea816cc02080ed64dcae1e89191b

# sepolia succ-v210
SEPOLIA_PARENT_HASH_SUCC_V210=0xe9c6363c2f2894ce09ede64e8123ea536c978741304106fb7ef9d73d8466ae95
SEPOLIA_CHILD_HASH_CLABS_SUCC_V210=0xd0dac870b6804424dfbd9e699a2fb365de2d0ed83507b0e647dd9f98f95f44ad
SEPOLIA_CHILD_DATA_CLABS_SUCC_V210=0x19010997447f88a2bb698764da0831cf77290b5f52333cf06515d7c747a213b37add91c9acda29eba8506aa7e913380b702a7903283c59a0ebcc086435595b63f36a
SEPOLIA_CHILD_SIG_CLABS_SUCC_V210=187d4822d299103825ef10f65ef04c17d8a2717a2d563c6383a1037df1d416e71c75a79ab8f4335f7310d0573d08ec64c7664b490d66f80468f3663ff6993e6b1b
SEPOLIA_CHILD_HASH_COUNCIL_SUCC_V210=0x49b8a0b7cf67dca65b91a064509dc601811e2d8b5c9076297e941761f7fe3217
SEPOLIA_CHILD_DATA_COUNCIL_SUCC_V210=0x1901cd00dbdd235174967fdd794795e947ae94fb2433442e6f497cbcb8ade286c3ff1b076146bc336f70b37650b8e3916a7fa3e05473f0652ec37a809b805251a0e1
SEPOLIA_CHILD_SIG_COUNCIL_SUCC_V210=78eb003c9369f140e5396e099f9175e3ca529026311d2647a54871e6ff85e85f4302b4e8ef089f811a9d4f490277548b69317133a2917196353567ce0ff4f9b21c

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

@test "Test check-version succ-v201" {
  run just check-version succ-v201
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succ-v201" ]
}

@test "Test check-version succ-v210" {
  run just check-version succ-v210
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: succ-v210" ]
}

@test "Test check-version eigenda-cert-v3" {
  run just check-version eigenda-cert-v3
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected version: eigenda-cert-v3" ]
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
  [ -f "upgrades/mainnet/09-succ-v201.json" ]
  [ -f "upgrades/mainnet/10-succ-v210.json" ]
  [ -f "upgrades/mainnet/11-eigenda-cert-v3.json" ]
}

@test "Test sepolia upgrade files exist" {
  [ -f "upgrades/sepolia/01-v4.json" ]
  [ -f "upgrades/sepolia/02-v5.json" ]
  [ -f "upgrades/sepolia/03-succ-v2.json" ]
  [ -f "upgrades/sepolia/04-succ-v210.json" ]
}

@test "Test mainnet address files exist" {
  [ -f "addresses/mainnet/01-v2.json" ]
  [ -f "addresses/mainnet/02-v3.json" ]
  [ -f "addresses/mainnet/03-succ-v1.json" ]
  [ -f "addresses/mainnet/04-succ-v102.json" ]
  [ -f "addresses/mainnet/05-v4.json" ]
  [ -f "addresses/mainnet/06-v5.json" ]
  [ -f "addresses/mainnet/07-succ-v2.json" ]
  [ -f "addresses/mainnet/09-succ-v201.json" ]
  [ -f "addresses/mainnet/10-succ-v210.json" ]
  [ -f "addresses/mainnet/11-eigenda-cert-v3.json" ]
}

@test "Test sepolia address files exist" {
  [ -f "addresses/sepolia/01-v4.json" ]
  [ -f "addresses/sepolia/02-v5.json" ]
  [ -f "addresses/sepolia/03-succ-v2.json" ]
  [ -f "addresses/sepolia/04-succ-v210.json" ]
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

@test "Test simulate succ-v201" {
  run just simulate succ-v201
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "succ-v201: $SIM_URL_SUCC_V201" ]
}

@test "Test simulate succ-v210" {
  run just simulate succ-v210
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "succ-v210: $SIM_URL_SUCC_V210" ]
}

@test "Test simulate eigenda-cert-v3" {
  run just simulate eigenda-cert-v3
  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "eigenda-cert-v3: $SIM_URL_EIGENDA_CERT_V3" ]
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

# --- v4 sign tests ---

@test "Test sign v4 clabs" {
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
  TEST_PK=$TEST_PK run just sign_ledger v4 clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V4" ]
}

@test "Test sign_ledger v4 clabs eth" {
  TEST_PK=$TEST_PK run just sign_ledger v4 clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V4" ]
}

@test "Test sign_ledger v4 council celo" {
  TEST_PK=$TEST_PK run just sign_ledger v4 council celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V4" ]
}

# --- v5 sign tests ---

@test "Test sign v5 clabs" {
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
  TEST_PK=$TEST_PK run just sign_ledger v5 clabs celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V5" ]
}

@test "Test sign_ledger v5 clabs eth" {
  TEST_PK=$TEST_PK run just sign_ledger v5 clabs eth
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_V5" ]
}

@test "Test sign_ledger v5 council celo" {
  TEST_PK=$TEST_PK run just sign_ledger v5 council celo
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_V5" ]
}

# --- succ-v2 sign tests ---

@test "Test sign succ-v2 clabs" {
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

# --- succ-v210 sign tests ---

@test "Test sign succ-v210 clabs" {
  TEST_PK=$TEST_PK run just sign succ-v210 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v210" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V210" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_SUCC_V210" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_SUCC_V210" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_SUCC_V210" ]
}

@test "Test sign succ-v210 council" {
  TEST_PK=$TEST_PK run just sign succ-v210 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v210" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V210" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCC_V210" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCC_V210" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_SUCC_V210" ]
}

@test "Test sign succ-v210 council with grand child" {
  TEST_PK=$TEST_PK run just sign succ-v210 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: succ-v210" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_SUCC_V210" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_SUCC_V210" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_SUCC_V210" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_SUCC_V210" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_SUCC_V210" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_SUCC_V210" ]
}

# --- eigenda-cert-v3 sign tests ---

@test "Test sign eigenda-cert-v3 clabs" {
  TEST_PK=$TEST_PK run just sign eigenda-cert-v3 clabs
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: eigenda-cert-v3" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_EIGENDA_CERT_V3" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_CLABS_EIGENDA_CERT_V3" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_CLABS_EIGENDA_CERT_V3" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_CLABS_EIGENDA_CERT_V3" ]
}

@test "Test sign eigenda-cert-v3 council" {
  TEST_PK=$TEST_PK run just sign eigenda-cert-v3 council
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: eigenda-cert-v3" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_EIGENDA_CERT_V3" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_EIGENDA_CERT_V3" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_EIGENDA_CERT_V3" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $CHILD_SIG_COUNCIL_EIGENDA_CERT_V3" ]
}

@test "Test sign eigenda-cert-v3 council with grand child" {
  TEST_PK=$TEST_PK run just sign eigenda-cert-v3 council "" $GRAND_CHILD_MULTISIG
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "Detected version: eigenda-cert-v3" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $PARENT_HASH_EIGENDA_CERT_V3" ]
  [ "${lines[4]}" = "Child tx hash: $CHILD_HASH_COUNCIL_EIGENDA_CERT_V3" ]
  [ "${lines[5]}" = "Child tx data: $CHILD_DATA_COUNCIL_EIGENDA_CERT_V3" ]
  [ "${lines[6]}" = "Attempting to generate payload for grand child at: $GRAND_CHILD_MULTISIG" ]
  [ "${lines[8]}" = "Grand child tx hash: $GRAND_CHILD_HASH_COUNCIL_EIGENDA_CERT_V3" ]
  [ "${lines[9]}" = "Grand child tx data: $GRAND_CHILD_DATA_COUNCIL_EIGENDA_CERT_V3" ]
  [ "${lines[10]}" = "Your account is $ACCOUNT" ]
  [ "${lines[11]}" = "Your signature for grand child tx hash: $GRAND_CHILD_SIG_COUNCIL_EIGENDA_CERT_V3" ]
}

# --- sepolia sign tests ---

@test "Test sign v4 clabs on sepolia" {
  NETWORK=sepolia TEST_PK=$TEST_PK run just sign v4 clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $SEPOLIA_PARENT_HASH_V4" ]
  [ "${lines[4]}" = "Child tx hash: $SEPOLIA_CHILD_HASH_CLABS_V4" ]
  [ "${lines[5]}" = "Child tx data: $SEPOLIA_CHILD_DATA_CLABS_V4" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $SEPOLIA_CHILD_SIG_CLABS_V4" ]
}

@test "Test sign v4 council on sepolia" {
  NETWORK=sepolia TEST_PK=$TEST_PK run just sign v4 council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
  [ "${lines[1]}" = "Detected version: v4" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $SEPOLIA_PARENT_HASH_V4" ]
  [ "${lines[4]}" = "Child tx hash: $SEPOLIA_CHILD_HASH_COUNCIL_V4" ]
  [ "${lines[5]}" = "Child tx data: $SEPOLIA_CHILD_DATA_COUNCIL_V4" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $SEPOLIA_CHILD_SIG_COUNCIL_V4" ]
}

@test "Test sign v5 clabs on sepolia" {
  NETWORK=sepolia TEST_PK=$TEST_PK run just sign v5 clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $SEPOLIA_PARENT_HASH_V5" ]
  [ "${lines[4]}" = "Child tx hash: $SEPOLIA_CHILD_HASH_CLABS_V5" ]
  [ "${lines[5]}" = "Child tx data: $SEPOLIA_CHILD_DATA_CLABS_V5" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $SEPOLIA_CHILD_SIG_CLABS_V5" ]
}

@test "Test sign v5 council on sepolia" {
  NETWORK=sepolia TEST_PK=$TEST_PK run just sign v5 council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
  [ "${lines[1]}" = "Detected version: v5" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $SEPOLIA_PARENT_HASH_V5" ]
  [ "${lines[4]}" = "Child tx hash: $SEPOLIA_CHILD_HASH_COUNCIL_V5" ]
  [ "${lines[5]}" = "Child tx data: $SEPOLIA_CHILD_DATA_COUNCIL_V5" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $SEPOLIA_CHILD_SIG_COUNCIL_V5" ]
}

@test "Test sign succ-v2 clabs on sepolia" {
  NETWORK=sepolia TEST_PK=$TEST_PK run just sign succ-v2 clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
  [ "${lines[1]}" = "Detected version: succ-v2" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $SEPOLIA_PARENT_HASH_SUCC_V2" ]
  [ "${lines[4]}" = "Child tx hash: $SEPOLIA_CHILD_HASH_CLABS_SUCC_V2" ]
  [ "${lines[5]}" = "Child tx data: $SEPOLIA_CHILD_DATA_CLABS_SUCC_V2" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $SEPOLIA_CHILD_SIG_CLABS_SUCC_V2" ]
}

@test "Test sign succ-v2 council on sepolia" {
  NETWORK=sepolia TEST_PK=$TEST_PK run just sign succ-v2 council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
  [ "${lines[1]}" = "Detected version: succ-v2" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $SEPOLIA_PARENT_HASH_SUCC_V2" ]
  [ "${lines[4]}" = "Child tx hash: $SEPOLIA_CHILD_HASH_COUNCIL_SUCC_V2" ]
  [ "${lines[5]}" = "Child tx data: $SEPOLIA_CHILD_DATA_COUNCIL_SUCC_V2" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $SEPOLIA_CHILD_SIG_COUNCIL_SUCC_V2" ]
}

@test "Test sign succ-v210 clabs on sepolia" {
  NETWORK=sepolia TEST_PK=$TEST_PK run just sign succ-v210 clabs
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
  [ "${lines[1]}" = "Detected version: succ-v210" ]
  [ "${lines[2]}" = "Detected team: clabs" ]
  [ "${lines[3]}" = "Parent tx hash: $SEPOLIA_PARENT_HASH_SUCC_V210" ]
  [ "${lines[4]}" = "Child tx hash: $SEPOLIA_CHILD_HASH_CLABS_SUCC_V210" ]
  [ "${lines[5]}" = "Child tx data: $SEPOLIA_CHILD_DATA_CLABS_SUCC_V210" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $SEPOLIA_CHILD_SIG_CLABS_SUCC_V210" ]
}

@test "Test sign succ-v210 council on sepolia" {
  NETWORK=sepolia TEST_PK=$TEST_PK run just sign succ-v210 council
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Detected network: sepolia" ]
  [ "${lines[1]}" = "Detected version: succ-v210" ]
  [ "${lines[2]}" = "Detected team: council" ]
  [ "${lines[3]}" = "Parent tx hash: $SEPOLIA_PARENT_HASH_SUCC_V210" ]
  [ "${lines[4]}" = "Child tx hash: $SEPOLIA_CHILD_HASH_COUNCIL_SUCC_V210" ]
  [ "${lines[5]}" = "Child tx data: $SEPOLIA_CHILD_DATA_COUNCIL_SUCC_V210" ]
  [ "${lines[6]}" = "Your account is $ACCOUNT" ]
  [ "${lines[7]}" = "Your signature for child tx hash: $SEPOLIA_CHILD_SIG_COUNCIL_SUCC_V210" ]
}
