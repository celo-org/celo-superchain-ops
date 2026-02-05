# Celo Superchain Ops - Project Documentation

This document describes how the project works for future AI agents working on this codebase.

## Project Overview

**Celo Superchain Ops** is a tool for coordinating multi-signature (multisig) transactions for Celo network upgrades. It enables council members to sign EIP-712 typed data using Ledger hardware wallets.

### Key Purpose

The project facilitates a **nested multisig approval flow**:
1. Individual council members sign transactions using their Ledger devices
2. Signatures are collected by a facilitator
3. Child Safe transactions (Council, cLabs) approve a parent transaction hash
4. Parent Safe executes the actual upgrade via delegatecall

---

## Architecture

### Multisig Hierarchy

```
Parent Safe (0x4092A77bAF58fef0309452cEaCb09221e556E112)
├── cLabs Safe (0x9Eb44Da23433b5cAA1c87e35594D15FcEb08D34d)
│   └── Individual signers (Ledger wallets)
└── Council Safe (0xC03172263409584f7860C25B6eB4985f0f6F4636)
    ├── Individual signers (Ledger wallets)
    └── Mento Safe (0xD1C635987B6Aa287361d08C6461491Fa9df087f2) - nested
        └── Individual signers (Ledger wallets)
```

### Signing Flow

```
Signer → EIP-712 Signature → JSON Output → Facilitator → Execute on Chain
```

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| Web UI | Vanilla HTML/CSS/JavaScript (single file) |
| Wallet Library | viem@2.x (via CDN) |
| Ledger USB | @ledgerhq/hw-transport-webhid, @ledgerhq/hw-app-eth |
| CLI Signing | eip712sign Go binary |
| Task Runner | Just (justfile) |
| Testing | Bats (bash testing) |
| Deployment | Vercel |

### No Build Step

The web UI is a self-contained HTML file with inline styles and ES module imports from CDN (esm.sh). No build process required.

---

## File Structure

```
CeloSuperchainOps/
├── signer/
│   └── index.html          # Main web UI (1500+ lines)
├── justfile                 # CLI task definitions
├── eip712sign               # Go binary for CLI signing
├── addresses/               # Contract addresses per upgrade
│   ├── v2.json
│   ├── v3.json
│   ├── succinct.json
│   └── succinct-v102.json
├── upgrades/                # Upgrade configurations
│   ├── v2.json
│   ├── v3.json
│   ├── succinct.json
│   └── succinct-v102.json
├── scripts/                 # Verification scripts
│   ├── decode_*.sh
│   └── compare_*.sh
├── .claude/                 # AI agent documentation
│   └── CLAUDE.md           # This file
├── README.md               # User documentation
├── TENDERLY.md             # Verification guide
└── test.sh                 # Bats test suite
```

---

## Web UI (signer/index.html)

### Current Features

1. **Team Selection**: Council or cLabs
2. **Member Type**: Regular or Mento (nested multisig)
3. **Derivation Path**: ETH (`m/44'/60'/...`) or Celo (`m/44'/52752'/...`)
4. **Platform Selection**: Mobile or PC (ETH path only)
5. **Connection Method**:
   - Mobile Wallet (MetaMask, Rabby, Rainbow, etc.)
   - Browser Wallet (MetaMask, Rabby, Rainbow, etc.)
   - WalletConnect / Ledger Live
   - Direct Ledger USB via WebHID (Celo path, desktop Chrome/Edge only)
6. **EIP-712 Signing**: SafeTx typed data
7. **Output**: JSON with version, hash, data, signature, account

### Key Constants

```javascript
const CONFIG = {
  version: 'succinct-v102',
  parentSafe: '0x4092A77bAF58fef0309452cEaCb09221e556E112',
  councilSafe: '0xC03172263409584f7860C25B6eB4985f0f6F4636',
  clabsSafe: '0x9Eb44Da23433b5cAA1c87e35594D15FcEb08F34d',
  mentoSafe: '0xD1C635987B6Aa287361d08C6461491Fa9df087f2',
  nonces: { council: 24n, clabs: 22n, mento: 6n },
  parentTxHash: '0xa17db5fb...',
  childTxHash: '0xb249f86c...',
  refundReceiver: '0x95ffac468e37ddeef407ffef18f0cc9e86d8f13b',
  gasToken: '0x0000000000000000000000000000000000000000'
}
```

### EIP-712 Types

```javascript
const SAFE_TX_TYPES = {
  SafeTx: [
    { name: 'to', type: 'address' },
    { name: 'value', type: 'uint256' },
    { name: 'data', type: 'bytes' },
    { name: 'operation', type: 'uint8' },
    { name: 'safeTxGas', type: 'uint256' },
    { name: 'baseGas', type: 'uint256' },
    { name: 'gasPrice', type: 'uint256' },
    { name: 'gasToken', type: 'address' },
    { name: 'refundReceiver', type: 'address' },
    { name: 'nonce', type: 'uint256' }
  ]
}
```

### Domain Structure

```javascript
const domain = {
  chainId: 1,  // Ethereum mainnet
  verifyingContract: safeAddress  // The Safe being signed for
}
```

---

## Derivation Paths

| Path Type | Pattern | Used By | Ledger App |
|-----------|---------|---------|------------|
| ETH | `m/44'/60'/<index>'/0/0` | MetaMask, most wallets | Ethereum |
| Celo | `m/44'/52752'/<index>'/0/0` | Celo-native wallets | Eth Recovery |

**Important**: The Celo Ledger app does NOT support EIP-712. Use **Eth Recovery** app for Celo derivation paths.

---

## Signing Methods

### 1. MetaMask (ETH Path)

```javascript
// Uses viem's walletClient
const signature = await walletClient.signTypedData({
  account: connectedAddress,
  domain,
  types: SAFE_TX_TYPES,
  primaryType: 'SafeTx',
  message
})
```

### 2. Direct Ledger USB (Celo Path)

```javascript
// Uses @ledgerhq/hw-app-eth
const result = await ledgerEthApp.signEIP712HashedMessage(
  path,                      // e.g., "m/44'/52752'/0'/0/0"
  domainSeparator.slice(2),  // Remove 0x prefix
  structHash.slice(2)        // Remove 0x prefix
)
```

### 3. CLI (justfile)

```bash
# Sign with Ledger
echo $TX_DATA | ./eip712sign -ledger -hd-paths "m/44'/52752'/0'/0/0"

# Sign with private key (testing)
echo $TX_DATA | ./eip712sign -private-key $PK
```

---

## Output Format

All signing methods produce the same JSON output:

```json
{
  "version": "succinct-v102",
  "hash": "0x...",      // EIP-712 typed data hash
  "data": "0x...",      // Encoded transaction data
  "sig": "...",         // Signature (without 0x prefix)
  "account": "0x..."    // Signer address
}
```

---

## Signer Types

| Type | Safe | Signs For | Nonce Key |
|------|------|-----------|-----------|
| council | Council Safe | Parent Safe | `council` |
| clabs | cLabs Safe | Parent Safe | `clabs` |
| mento | Mento Safe | Council Safe | `mento` |

### Transaction Data

- **Council/cLabs**: Sign `approveHash(parentTxHash)` for Parent Safe
- **Mento**: Sign `approveHash(childTxHash)` for Council Safe (nested)

---

## UI State Management

```javascript
let walletClient = null
let connectedAddress = null
let selectedTeam = 'council'        // 'council' | 'clabs'
let selectedMemberType = 'regular'  // 'regular' | 'mento'
let selectedDerivationPath = 'eth'  // 'eth' | 'celo'
let selectedPlatform = 'mobile'     // 'mobile' | 'pc'
let selectedConnectionMethod = 'metamask'  // 'metamask' | 'walletconnect' | 'ledger-usb'
let ledgerTransport = null
let ledgerEthApp = null
let wcProvider = null               // WalletConnect provider
```

---

## Key Functions

| Function | Purpose |
|----------|---------|
| `connect()` | Connect browser/mobile wallet |
| `connectLedgerUSB()` | Connect Ledger via WebHID |
| `connectWalletConnect()` | Connect via WalletConnect QR |
| `disconnect()` | Disconnect wallet/Ledger/WalletConnect |
| `sign()` | Sign the transaction |
| `signWithLedger()` | EIP-712 signing via Ledger |
| `getSignerType()` | Determine signer type from selections |
| `getSigningParams()` | Get parameters for current signer type |
| `getAvailableConnectionMethods()` | Get connection methods for current platform/path |
| `renderConnectionMethods()` | Render connection method radio options |
| `updateRoleUI()` | Update UI based on role selection |
| `updateDerivationPathUI()` | Update UI based on path selection |
| `updateConnectionUI()` | Update connection status display |
| `showWalletConnectQR()` | Display WalletConnect QR modal |
| `showWcSigningModal()` | Show signing-in-progress modal |

---

## Error Handling

### Ledger Error Codes

| Code | Meaning |
|------|---------|
| 27904 | Device locked |
| 25873, 27906 | App not open |
| 27013 | User rejected on device |
| NotFoundError | No device selected |

### MetaMask Error Codes

| Code | Meaning |
|------|---------|
| 4001 | User rejected request |

---

## Testing

### Bats Tests (test.sh)

```bash
# Run tests
RPC_URL=https://ethereum-rpc.publicnode.com ./test.sh

# Tests use TEST_PK for reproducible signatures
```

### CI Pipeline

Located in `.github/workflows/run_bats.yml`:
1. Install mise + dependencies
2. Install eip712sign tool
3. Run bats tests

---

## Upgrade Configuration

Each upgrade version has:

### addresses/<version>.json
```json
{
  "parentSafe": "0x...",
  "councilSafe": "0x...",
  "clabsSafe": "0x...",
  "mentoSafe": "0x..."
}
```

### upgrades/<version>.json
```json
{
  "target": "0x...",
  "calldata": "0x...",
  "nonce": {
    "parent": 5,
    "council": 24,
    "clabs": 22,
    "mento": 6
  }
}
```

---

## Common Tasks

### Adding a New Upgrade Version

1. Create `addresses/<version>.json` with Safe addresses
2. Create `upgrades/<version>.json` with target, calldata, nonces
3. Update `CONFIG.version` in `signer/index.html`
4. Update nonces and hashes in the web UI
5. Add verification script in `scripts/`

### Updating Nonces

When upgrades are executed, increment the relevant nonce in:
- `upgrades/<version>.json`
- `signer/index.html` CONFIG object

### Testing Signatures

```bash
# Use justfile with test private key
just sign_test succinct-v102 council eth 0

# Verify output matches expected
```

---

## Design Patterns

### CSS Custom Properties

```css
--primary: #35D07F;       /* Celo green */
--primary-dark: #2BB56A;
--bg: #FAFAFA;
--card: #FFFFFF;
--text: #1A1A1A;
--text-secondary: #666666;
--border: #E5E5E5;
--error: #DC3545;
--success: #28A745;
```

### Component Patterns

- **Card**: White background with subtle shadow, 12px border-radius
- **Tab Container**: Pill-style tabs with active state
- **Radio Group**: Custom styled radios with selection state
- **Steps List**: Numbered list with green circular badges
- **Info Box**: Blue left-border callout
- **Warning Box**: Yellow/amber left-border callout
- **Output Box**: Dark terminal-style display

---

## External Dependencies (CDN)

| Package | CDN URL | Purpose |
|---------|---------|---------|
| viem | esm.sh/viem@2.x | Wallet client, EIP-712 |
| hw-transport-webhid | cdn.skypack.dev/@ledgerhq/hw-transport-webhid@6.28.6 | Ledger USB |
| hw-app-eth | esm.sh/@ledgerhq/hw-app-eth@6.29.0 | Ledger Ethereum app |
| ethereum-provider | esm.sh/@walletconnect/ethereum-provider@2.23.4 | WalletConnect |
| qrcode | esm.sh/qrcode@1.5.4 | QR code generation |

---

## Security Considerations

1. **Never commit private keys** - Use environment variables for testing
2. **Verify transaction hashes** - Always check against Tenderly simulation
3. **Use hardware wallets** - Ledger required for production signatures
4. **Check addresses** - Verify Safe addresses before signing
5. **Review calldata** - Use decode scripts to verify transaction content

---

## WalletConnect Integration

WalletConnect support enables signing via Ledger Live mobile app and other WalletConnect-compatible wallets.

### Key Features
- Platform selection (Mobile/PC)
- Connection method selection (Mobile Wallet, Browser Wallet, WalletConnect, Direct USB)
- QR code modal for WalletConnect pairing
- Signing modal with feedback during WalletConnect signing
- Deep link support for Ledger Live app

### WalletConnect Project ID
```javascript
const WALLETCONNECT_PROJECT_ID = '855eb261fad42347d0a8baf068679887'
```

### Supported Devices via WalletConnect
- Ledger Nano X via Bluetooth (iOS/Android)
- Ledger Nano S/S+ via USB OTG (Android only)
- Any WalletConnect-compatible wallet

---

## Future Improvements

- Add "Copy URI" button as fallback for WalletConnect deep link
- Consider session persistence for WalletConnect
- Add transaction simulation preview
