# Blockchain Lib

A comprehensive Flutter library for blockchain operations including BIP32, BIP39, BIP44, Web3Dart, Solana and BS58 support.

## Features

- **BIP39**: Mnemonic code for generating deterministic keys
- **BIP32**: Hierarchical Deterministic Wallets
- **BIP44**: Multi-Account Hierarchy for Deterministic Wallets
- **Ethereum**: Full Web3Dart integration for Ethereum blockchain
- **Solana**: Solana blockchain support with RPC integration
- **BS58**: Base58 encoding/decoding utilities
- **Account Management**: Complete account generation and management
- **Transaction Support**: Send transactions on Ethereum and Solana
- **Balance Queries**: Get account balances for both Ethereum and Solana
- **Airdrop Support**: Request airdrops for testing on both networks
- **Transfer Operations**: Transfer tokens between accounts

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  blockchain_lib: ^1.0.0
```

## Quick Start

```dart
import 'package:blockchain_lib/blockchain_lib.dart';

void main() {
  final blockchainService = BlockchainService();
  
  // Generate a new mnemonic
  final mnemonic = blockchainService.generateMnemonic();
  print('Mnemonic: $mnemonic');
  
  // Generate Ethereum account
  final ethPath = blockchainService.generateEthereumPath(0);
  final ethAccount = blockchainService.generateAccountFromMnemonic(mnemonic, ethPath);
  print('Ethereum Address: ${ethAccount['address']}');
  
  // Generate Solana account
  final solPath = blockchainService.generateSolanaPath(0);
  final solAccount = blockchainService.generateAccountFromMnemonic(mnemonic, solPath);
  print('Solana Address: ${solAccount['address']}');
  
  // Get balances
  final ethBalance = await blockchainService.getEthereumBalance(ethAccount['address'], 'http://localhost:8545');
  final solBalance = await blockchainService.getSolanaBalance(solAccount['address'], 'http://localhost:8899');
  print('Ethereum Balance: $ethBalance ETH');
  print('Solana Balance: $solBalance SOL');
}
```

## Usage

### BIP39 - Mnemonic Operations

```dart
final blockchainService = BlockchainService();

// Generate a new mnemonic
String mnemonic = blockchainService.generateMnemonic();

// Validate a mnemonic
bool isValid = blockchainService.validateMnemonic(mnemonic);

// Convert mnemonic to seed
Uint8List seed = blockchainService.mnemonicToSeed(mnemonic);

// Convert mnemonic to seed with passphrase
Uint8List seedWithPassphrase = blockchainService.mnemonicToSeedWithPassphrase(
  mnemonic, 
  'my-passphrase'
);
```

### BIP32 - Hierarchical Deterministic Wallets

```dart
// Create BIP32 root from seed
bip32.BIP32 root = blockchainService.createBIP32Root(seed);

// Derive child using path
bip32.BIP32 child = blockchainService.derivePath(root, "m/44'/60'/0'/0/0");

// Derive child using index
bip32.BIP32 childByIndex = blockchainService.deriveChild(root, 0);
```

### BIP44 - Multi-Account Hierarchy

```dart
// Generate Ethereum derivation path
String ethPath = blockchainService.generateEthereumPath(0); // m/44'/60'/0'/0/0

// Generate Solana derivation path
String solPath = blockchainService.generateSolanaPath(0); // m/44'/501'/0'/0/0

// Validate derivation path
bool isValidPath = blockchainService.isValidDerivationPath(ethPath);

// Extract derivation index
int index = blockchainService.extractDerivationIndex(ethPath);
```

### Account Generation

```dart
// Generate complete account from mnemonic and path
Map<String, dynamic> account = blockchainService.generateAccountFromMnemonic(
  mnemonic,
  ethPath
);

print('Address: ${account['address']}');
print('Private Key: ${account['privateKey']}');
print('Derivation Index: ${account['derivationIndex']}');
print('Derivation Path: ${account['derivationPath']}');
```

### Ethereum Operations

```dart
// Create Ethereum private key
web3.EthPrivateKey privateKey = blockchainService.createEthereumPrivateKeyFromHex(
  '0x1234567890abcdef...'
);

// Get Ethereum address
String address = blockchainService.getEthereumAddress(privateKey);

// Validate Ethereum address
bool isValidAddress = blockchainService.isValidEthereumAddress(address);

// Get account balance
String balance = await blockchainService.getEthereumBalance(
  address,
  'https://mainnet.infura.io/v3/YOUR_PROJECT_ID'
);

// Send transaction
String txHash = await blockchainService.transferEthereum(
  fromAccount,
  toAddress,
  amount,
  endpointUrl
);

// Request ETH airdrop
String airdropHash = await blockchainService.airdropEthereum(
  toAddress,
  amount,
  endpointUrl
);
```

### Solana Operations

```dart
// Check if path is for Solana
bool isSolana = blockchainService.isSolanaPath("m/44'/501'/0'/0/0");

// Generate Solana address
String solanaAddress = blockchainService.generateSolanaAddressFromBytes(privateKeyBytes);

// Get Solana balance
String balance = await blockchainService.getSolanaBalance(address, 'http://localhost:8899');

// Transfer SOL
String txHash = await blockchainService.transferSolana(
  fromAccount,
  toAddress,
  amount,
  endpointUrl
);

// Request SOL airdrop
String airdropHash = await blockchainService.airdropSolana(
  toAddress,
  amount,
  endpointUrl
);
```

### BS58 Operations

```dart
// Encode to Base58
String encoded = blockchainService.encodeBase58(bytes);

// Decode from Base58
Uint8List decoded = blockchainService.decodeBase58(encoded);
```

### Transfer and Airdrop Operations

```dart
// Ethereum Transfer
String ethTxHash = await blockchainService.transferEthereum(
  fromAccount,
  toAddress,
  '0.001', // amount in ETH
  'http://localhost:8545'
);

// Solana Transfer
String solTxHash = await blockchainService.transferSolana(
  fromAccount,
  toAddress,
  '0.1', // amount in SOL
  'http://localhost:8899'
);

// Ethereum Airdrop
String ethAirdropHash = await blockchainService.airdropEthereum(
  toAddress,
  '1.0', // amount in ETH
  'http://localhost:8545'
);

// Solana Airdrop
String solAirdropHash = await blockchainService.airdropSolana(
  toAddress,
  '1.0', // amount in SOL
  'http://localhost:8899'
);
```

### Utility Functions

```dart
// Validate amount
bool isValidAmount = blockchainService.isValidAmount("1.5");

// Get chain information
Map<String, dynamic> chainInfo = await blockchainService.getChainInfo(endpointUrl);
print('Chain ID: ${chainInfo['chainId']}');
print('Chain ID Hex: ${chainInfo['chainIdHex']}');
```

## Data Structures

The library uses basic Dart types (Map, String, etc.) instead of custom classes to avoid coupling:

### Account (Map<String, dynamic>)

```dart
Map<String, dynamic> account = {
  'address': '0x1234567890abcdef',
  'privateKey': '0xabcdef1234567890',
  'derivationIndex': 0,
  'derivationPath': "m/44'/60'/0'/0/0",
};
```

### Chain Info (Map<String, dynamic>)

```dart
Map<String, dynamic> chainInfo = {
  'chainId': 1,
  'chainIdHex': '0x1',
  'endpointUrl': 'https://mainnet.infura.io/v3/project',
};
```

## Example

See the `example/` directory for a complete Flutter app demonstrating the library usage.

## Dependencies

- `http`: ^1.1.0
- `bip39`: ^1.0.3
- `bip32`: ^2.0.0
- `web3dart`: ^2.7.2
- `bs58`: ^2.0.0

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This library is for educational and development purposes. Always follow security best practices when handling private keys and sensitive data in production applications.
