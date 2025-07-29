# My Flutter Library

A Flutter library that provides database functionality using SQLite for managing cryptocurrency wallet data.

## Features

- **SQLite Database**: Local database storage using `sqflite` package
- **CRUD Operations**: Complete Create, Read, Update, Delete operations for all models
- **Repository Pattern**: Clean architecture with repository classes
- **Foreign Key Relationships**: Proper relationships between tables with CASCADE deletes
- **Advanced Queries**: Complex queries with JOINs for detailed data retrieval

## Models

### Account
```dart
class Account {
  final int? id;
  final int mnemonicId;
  final String name;
  final String address;
  final int derivationIndex;
  final String derivationPathPattern;
  final DateTime createdAt;
}
```

### Mnemonic
```dart
class Mnemonic {
  final int? id;
  final String name;
  final String mnemonic;
  final String passphrase;
  final String masterKey;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Endpoint
```dart
class Endpoint {
  final int? id;
  final String name;
  final String url;
  final String chanId;
  final DateTime createdAt;
}
```

### Balance
```dart
class Balance {
  final int? id;
  final int accountId;
  final int endpointId;  
  final String balance;
  final DateTime createdAt;
}
```

## Database Schema

The library creates the following SQLite tables:

- **mnemonics**: Stores wallet mnemonics and master keys
- **accounts**: Stores derived accounts linked to mnemonics
- **endpoints**: Stores blockchain RPC endpoints
- **balances**: Stores account balances for specific endpoints

## Usage

### Basic Setup

```dart
import 'package:my_flutter_lib/my_flutter_lib.dart';

// Initialize repositories
final mnemonicRepo = MnemonicRepository();
final accountRepo = AccountRepository();
final endpointRepo = EndpointRepository();
final balanceRepo = BalanceRepository();
```

### Create Operations

```dart
// Create a new mnemonic
final mnemonicId = await mnemonicRepo.createNewMnemonic(
  name: 'My Wallet',
  mnemonic: 'abandon abandon abandon...',
  passphrase: 'my_passphrase',
  masterKey: 'master_key_here',
);

// Create a new account
final accountId = await accountRepo.createNewAccount(
  mnemonicId: mnemonicId,
  name: 'Account 1',
  address: 'cosmos1abc123...',
  derivationIndex: 0,
  derivationPathPattern: "m/44'/118'/0'/0/0",
);

// Create a new endpoint
final endpointId = await endpointRepo.createNewEndpoint(
  name: 'Cosmos Hub',
  url: 'https://rpc.cosmos.network',
  chanId: 'cosmoshub-4',
);

// Create a new balance
final balanceId = await balanceRepo.createNewBalance(
  accountId: accountId,
  endpointId: endpointId,
  balance: '1000000uatom',
);
```

### Read Operations

```dart
// Get all mnemonics
final mnemonics = await mnemonicRepo.getAllMnemonics();

// Get accounts by mnemonic ID
final accounts = await accountRepo.getAccountsByMnemonicId(mnemonicId);

// Get balances with account and endpoint details
final balanceDetails = await balanceRepo.getAllBalancesWithDetails();
```

### Update Operations

```dart
// Update a mnemonic
final mnemonic = await mnemonicRepo.getMnemonicById(1);
if (mnemonic != null) {
  final updatedMnemonic = mnemonic.copyWith(name: 'Updated Name');
  await mnemonicRepo.updateMnemonicWithTimestamp(updatedMnemonic);
}
```

### Delete Operations

```dart
// Delete operations (CASCADE will handle related records)
await balanceRepo.deleteBalance(1);
await accountRepo.deleteAccount(1);
await endpointRepo.deleteEndpoint(1);
await mnemonicRepo.deleteMnemonic(1);
```

## Advanced Queries

The library provides advanced query methods for complex data retrieval:

```dart
// Get account with mnemonic details
final accountWithMnemonic = await accountRepo.getAccountWithMnemonic(accountId);

// Get balance with account and endpoint details
final balanceWithDetails = await balanceRepo.getBalanceWithDetails(balanceId);

// Get all balances with complete details
final allBalancesWithDetails = await balanceRepo.getAllBalancesWithDetails();
```

## Dependencies

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  sqflite: ^2.3.2
  path: ^1.8.3
```

## Example

See `lib/example_usage.dart` for complete usage examples including:
- Basic CRUD operations
- Complete workflow examples
- Error handling
- Advanced queries
