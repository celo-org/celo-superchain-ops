# Manual Verification on Tenderly

To manually verify the upgrades, please follow these steps:
1. Open the Tenderly link for the specific version (v2 or v3).
2. Turn on "dev mode" in the Tenderly interface (top right corner).
3. Navigate to the "Storage changes" tab.
4. Search for the proxy address in the "Storage Changes" tab.
5. Click on "show raw state changes" for that proxy.
6. Verify that the "After:" value contains the new implementation address as listed in the tables below.

# v2 Implementation

Tenderly link for v2: https://dashboard.tenderly.co/explorer/vnet/4c92d88c-598f-42fd-bfdc-c837b8d697cc/tx/0x7c44fe8c5c48931a322f0b986957c677b8871922ab152307e06f7319cd85f639

| Contract                             | Contract to check                            | v2 Implementation                            |
| ------------------------------------ | -------------------------------------------- | -------------------------------------------- |
| DelayedWETHImpl                      | a316D42E8Fd98D2Ec364b8bF853d2623E768f95a   | 1e121e21e1a11ae47c0efe8a7e13ae3eb4923796   |
| OptimismPortal2Impl                  | c5c5D157928BDBD2ACf6d0777626b6C75a9EAEDC   | bed463769920dac19a7e2adf47b6c6bb6480bd97   |
| SystemConfigImpl                     | 89E31965D844a309231B1f17759Ccaf1b7c09861   | 911ea44d22eb903515378625da3a0e09d2e1b074   |
| L1CrossDomainMessengerImpl           | 55093104b76FAA602F9d6c35A5FFF576bE78d753   | 3d5a67747de7e09b0d71f5d782c8b45f6307b9fd   |
| L1ERC721BridgeImpl                   | 3C519816C5BdC0a0199147594F83feD4F5847f13   | 276d3730f219f7ec22274f7263180b8452b46d47   |
| L1StandardBridgeImpl                 | 9C4955b92F34148dbcfDCD82e9c9eCe5CF2badfe   | af38504abc62f28e419622506698c5fa3ca15eda   |
| OptimismMintableERC20FactoryImpl     | 6f0E4f1EB98A52EfaCF7BE11d48B9d9d6510A906   | 5493f4677a186f64805fe7317d6993ba4863988f   |
| DisputeGameFactoryImpl               | FbAC162162f4009Bb007C6DeBC36B1dAC10aF683   | 4bba758f006ef09402ef31724203f316ab74e4a0   |
| ProtocolVersionsImpl                 | 1b6dEB2197418075AB314ac4D52Ca1D104a8F663   | 37e15e4d6dffa9e5e320ee1ec036922e563cb76c   |

# v3 Implementation

Tenderly link for v3: https://dashboard.tenderly.co/explorer/vnet/4c92d88c-598f-42fd-bfdc-c837b8d697cc/tx/0x8d37735f7be725450d35187ea24f9050341a601817a2152c6fefa7a1192597da

| Contract                             | Contract to check                                 | v3 Implementation                            |
| ------------------------------------ | -------------------------------------------- | -------------------------------------------- |
| OptimismPortal2                  | c5c5D157928BDBD2ACf6d0777626b6C75a9EAEDC   | 215a5ff85308a72a772f09b520da71d3520e9ac7   |
| SystemConfig                     | 89E31965D844a309231B1f17759Ccaf1b7c09861   | 9c61c5a8ff9408b83ac92571278550097a9d2bb5   |
| L1CrossDomainMessenger           | 0x55093104b76FAA602F9d6c35A5FFF576bE78d753   | 807124f75ff2120b2f26d7e6f9e39c03ee9de212   |
| L1ERC721Bridge                   | 3C519816C5BdC0a0199147594F83feD4F5847f13   | 7ae1d3bd877a4c5ca257404ce26be93a02c98013   |
| L1StandardBridge                 | 9C4955b92F34148dbcfDCD82e9c9eCe5CF2badfe   | 28841965b26d41304905a836da5c0921da7dbb84   |

# succinct (OpSuccinct v1.0.0) Upgrade

Tenderly link for succinct: https://dashboard.tenderly.co/explorer/vnet/053b540e-ae59-42c8-80a0-1250820dc894/tx/0x55742ec449b9659f3a5662c5b2f6d6a92d9d955a39eeaaeaf1df1726a3f2ff3f

Verify the following changes:
- `initBonds[42]` is set to `10000000000000000` (0.01 ETH)
- `gameImpls[42]` points to `0x113f434f82FF82678AE7f69Ea122791FE1F6b73e` (OPSuccinctFaultDisputeGame)

| Contract                             | Address                                      |
| ------------------------------------ | -------------------------------------------- |
| AccessManager                        | 0xf59a19c5578291cb7fd22618d16281adf76f2816   |
| OPSuccinctFaultDisputeGame          | 0x113f434f82ff82678ae7f69ea122791fe1f6b73e   |

# succinct-v102 (OpSuccinct v1.0.2) Upgrade

Tenderly link for succinct-v102: https://dashboard.tenderly.co/explorer/vnet/39498d1a-4638-47d3-8bbc-010de8f718ce/tx/0x27f7a467c7d7faa3aa9934ffc2810a4d910e2404783aed427a5fa1f732f7e12d

Verify the following change:
- `gameImpls[42]` is updated to `0xc5bd131ceaeb72f15c66418bc2668332ab99de37` (OPSuccinctFaultDisputeGame v1.0.2)

## Deployed Contracts

| Contract                             | Address                                      |
| ------------------------------------ | -------------------------------------------- |
| AccessManager                        | 0xf59a19c5578291cb7fd22618d16281adf76f2816   |
| OPSuccinctFaultDisputeGame          | 0xc5bd131ceaeb72f15c66418bc2668332ab99de37   |
