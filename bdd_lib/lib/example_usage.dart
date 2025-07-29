import 'package:my_flutter_lib/my_flutter_lib.dart';

/// Example usage of the database operations
class ExampleUsage {
  final MnemonicRepository _mnemonicRepo = MnemonicRepository();
  final AccountRepository _accountRepo = AccountRepository();
  final EndpointRepository _endpointRepo = EndpointRepository();
  final BalanceRepository _balanceRepo = BalanceRepository();

  /// Example: Create a new mnemonic
  Future<void> createMnemonicExample() async {
    try {
      final mnemonicId = await _mnemonicRepo.createNewMnemonic(
        name: 'My Wallet',
        mnemonic:
            'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
        passphrase: 'my_passphrase',
        masterKey: 'master_key_here',
      );
      print('Created mnemonic with ID: $mnemonicId');
    } catch (e) {
      print('Error creating mnemonic: $e');
    }
  }

  /// Example: Create a new account
  Future<void> createAccountExample() async {
    try {
      final accountId = await _accountRepo.createNewAccount(
        mnemonicId: 1, // Assuming mnemonic with ID 1 exists
        name: 'Account 1',
        address: 'cosmos1abc123...',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/118'/0'/0/0",
      );
      print('Created account with ID: $accountId');
    } catch (e) {
      print('Error creating account: $e');
    }
  }

  /// Example: Create a new endpoint
  Future<void> createEndpointExample() async {
    try {
      final endpointId = await _endpointRepo.createNewEndpoint(
        name: 'Cosmos Hub',
        url: 'https://rpc.cosmos.network',
        chanId: 'cosmoshub-4',
      );
      print('Created endpoint with ID: $endpointId');
    } catch (e) {
      print('Error creating endpoint: $e');
    }
  }

  /// Example: Create a new balance
  Future<void> createBalanceExample() async {
    try {
      final balanceId = await _balanceRepo.createNewBalance(
        accountId: 1, // Assuming account with ID 1 exists
        endpointId: 1, // Assuming endpoint with ID 1 exists
        balance: '1000000uatom',
      );
      print('Created balance with ID: $balanceId');
    } catch (e) {
      print('Error creating balance: $e');
    }
  }

  /// Example: Get all mnemonics
  Future<void> getAllMnemonicsExample() async {
    try {
      final mnemonics = await _mnemonicRepo.getAllMnemonics();
      print('Found ${mnemonics.length} mnemonics:');
      for (final mnemonic in mnemonics) {
        print('- ${mnemonic.name}: ${mnemonic.mnemonic}');
      }
    } catch (e) {
      print('Error getting mnemonics: $e');
    }
  }

  /// Example: Get accounts by mnemonic ID
  Future<void> getAccountsByMnemonicExample() async {
    try {
      final accounts = await _accountRepo.getAccountsByMnemonicId(1);
      print('Found ${accounts.length} accounts for mnemonic 1:');
      for (final account in accounts) {
        print('- ${account.name}: ${account.address}');
      }
    } catch (e) {
      print('Error getting accounts: $e');
    }
  }

  /// Example: Get balance with details
  Future<void> getBalanceWithDetailsExample() async {
    try {
      final balanceDetails = await _balanceRepo.getBalanceWithDetails(1);
      if (balanceDetails.isNotEmpty) {
        final details = balanceDetails.first;
        print('Balance details:');
        print('- Account: ${details['account_name']}');
        print('- Address: ${details['address']}');
        print('- Endpoint: ${details['endpoint_name']}');
        print('- URL: ${details['url']}');
        print('- Balance: ${details['balance']}');
      }
    } catch (e) {
      print('Error getting balance details: $e');
    }
  }

  /// Example: Update a mnemonic
  Future<void> updateMnemonicExample() async {
    try {
      final mnemonic = await _mnemonicRepo.getMnemonicById(1);
      if (mnemonic != null) {
        final updatedMnemonic = mnemonic.copyWith(name: 'Updated Wallet Name');
        await _mnemonicRepo.updateMnemonicWithTimestamp(updatedMnemonic);
        print('Updated mnemonic successfully');
      }
    } catch (e) {
      print('Error updating mnemonic: $e');
    }
  }

  /// Example: Delete operations
  Future<void> deleteExamples() async {
    try {
      // Delete a balance
      await _balanceRepo.deleteBalance(1);
      print('Deleted balance with ID 1');

      // Delete an account
      await _accountRepo.deleteAccount(1);
      print('Deleted account with ID 1');

      // Delete an endpoint
      await _endpointRepo.deleteEndpoint(1);
      print('Deleted endpoint with ID 1');

      // Delete a mnemonic (this will also delete related accounts due to CASCADE)
      await _mnemonicRepo.deleteMnemonic(1);
      print('Deleted mnemonic with ID 1');
    } catch (e) {
      print('Error in delete operations: $e');
    }
  }

  /// Example: Complete workflow
  Future<void> completeWorkflowExample() async {
    try {
      // 1. Create a mnemonic
      final mnemonicId = await _mnemonicRepo.createNewMnemonic(
        name: 'Test Wallet',
        mnemonic:
            'test test test test test test test test test test test test junk',
        passphrase: 'test_passphrase',
        masterKey: 'test_master_key',
      );

      // 2. Create an account for this mnemonic
      final accountId = await _accountRepo.createNewAccount(
        mnemonicId: mnemonicId,
        name: 'Test Account',
        address: 'cosmos1test123...',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/118'/0'/0/0",
      );

      // 3. Create an endpoint
      final endpointId = await _endpointRepo.createNewEndpoint(
        name: 'Test Endpoint',
        url: 'https://test-rpc.example.com',
        chanId: 'test-chain-1',
      );

      // 4. Create a balance
      final balanceId = await _balanceRepo.createNewBalance(
        accountId: accountId,
        endpointId: endpointId,
        balance: '5000000uatom',
      );

      print('Complete workflow completed successfully!');
      print('- Mnemonic ID: $mnemonicId');
      print('- Account ID: $accountId');
      print('- Endpoint ID: $endpointId');
      print('- Balance ID: $balanceId');

      // 5. Get all balances with details
      final allBalances = await _balanceRepo.getAllBalancesWithDetails();
      print('All balances with details:');
      for (final balance in allBalances) {
        print(
          '- ${balance['account_name']} on ${balance['endpoint_name']}: ${balance['balance']}',
        );
      }
    } catch (e) {
      print('Error in complete workflow: $e');
    }
  }
}
