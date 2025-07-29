import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:my_flutter_lib/my_flutter_lib.dart';

void main() {
  group('Database Tests', () {
    late MnemonicRepository mnemonicRepo;
    late AccountRepository accountRepo;
    late EndpointRepository endpointRepo;
    late BalanceRepository balanceRepo;

    setUpAll(() {
      // Initialize sqflite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      mnemonicRepo = MnemonicRepository();
      accountRepo = AccountRepository();
      endpointRepo = EndpointRepository();
      balanceRepo = BalanceRepository();
    });

    test('Create and retrieve mnemonic', () async {
      // Create a new mnemonic
      final mnemonicId = await mnemonicRepo.createNewMnemonic(
        name: 'Test Wallet',
        mnemonic:
            'test test test test test test test test test test test test junk',
        passphrase: 'test_passphrase',
        masterKey: 'test_master_key',
      );

      expect(mnemonicId, isA<int>());
      expect(mnemonicId, greaterThan(0));

      // Retrieve the mnemonic
      final mnemonic = await mnemonicRepo.getMnemonicById(mnemonicId);
      expect(mnemonic, isNotNull);
      expect(mnemonic!.name, equals('Test Wallet'));
      expect(
        mnemonic.mnemonic,
        equals(
          'test test test test test test test test test test test test junk',
        ),
      );
    });

    test('Create and retrieve account', () async {
      // First create a mnemonic
      final mnemonicId = await mnemonicRepo.createNewMnemonic(
        name: 'Test Wallet',
        mnemonic: 'test test test test test test test test test test test junk',
        passphrase: 'test_passphrase',
        masterKey: 'test_master_key',
      );

      // Create an account
      final accountId = await accountRepo.createNewAccount(
        mnemonicId: mnemonicId,
        name: 'Test Account',
        address: 'cosmos1test123...',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/118'/0'/0/0",
      );

      expect(accountId, isA<int>());
      expect(accountId, greaterThan(0));

      // Retrieve the account
      final account = await accountRepo.getAccountById(accountId);
      expect(account, isNotNull);
      expect(account!.name, equals('Test Account'));
      expect(account.address, equals('cosmos1test123...'));
      expect(account.mnemonicId, equals(mnemonicId));
    });

    test('Create and retrieve endpoint', () async {
      // Create an endpoint
      final endpointId = await endpointRepo.createNewEndpoint(
        name: 'Test Endpoint',
        url: 'https://test-rpc.example.com',
        chanId: 'test-chain-1',
      );

      expect(endpointId, isA<int>());
      expect(endpointId, greaterThan(0));

      // Retrieve the endpoint
      final endpoint = await endpointRepo.getEndpointById(endpointId);
      expect(endpoint, isNotNull);
      expect(endpoint!.name, equals('Test Endpoint'));
      expect(endpoint.url, equals('https://test-rpc.example.com'));
      expect(endpoint.chanId, equals('test-chain-1'));
    });

    test('Create and retrieve balance', () async {
      // Create dependencies
      final mnemonicId = await mnemonicRepo.createNewMnemonic(
        name: 'Test Wallet',
        mnemonic: 'test test test test test test test test test test test junk',
        passphrase: 'test_passphrase',
        masterKey: 'test_master_key',
      );

      final accountId = await accountRepo.createNewAccount(
        mnemonicId: mnemonicId,
        name: 'Test Account',
        address: 'cosmos1test123...',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/118'/0'/0/0",
      );

      final endpointId = await endpointRepo.createNewEndpoint(
        name: 'Test Endpoint',
        url: 'https://test-rpc.example.com',
        chanId: 'test-chain-1',
      );

      // Create a balance
      final balanceId = await balanceRepo.createNewBalance(
        accountId: accountId,
        endpointId: endpointId,
        balance: '1000000uatom',
      );

      expect(balanceId, isA<int>());
      expect(balanceId, greaterThan(0));

      // Retrieve the balance
      final balance = await balanceRepo.getBalanceById(balanceId);
      expect(balance, isNotNull);
      expect(balance!.accountId, equals(accountId));
      expect(balance.endpointId, equals(endpointId));
      expect(balance.balance, equals('1000000uatom'));
    });

    test('Get accounts by mnemonic ID', () async {
      // Create a mnemonic
      final mnemonicId = await mnemonicRepo.createNewMnemonic(
        name: 'Test Wallet',
        mnemonic: 'test test test test test test test test test test test junk',
        passphrase: 'test_passphrase',
        masterKey: 'test_master_key',
      );

      // Create multiple accounts for the same mnemonic
      await accountRepo.createNewAccount(
        mnemonicId: mnemonicId,
        name: 'Account 1',
        address: 'cosmos1account1...',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/118'/0'/0/0",
      );

      await accountRepo.createNewAccount(
        mnemonicId: mnemonicId,
        name: 'Account 2',
        address: 'cosmos1account2...',
        derivationIndex: 1,
        derivationPathPattern: "m/44'/118'/0'/0/1",
      );

      // Get accounts by mnemonic ID
      final accounts = await accountRepo.getAccountsByMnemonicId(mnemonicId);
      expect(accounts.length, equals(2));
      expect(accounts.any((a) => a.name == 'Account 1'), isTrue);
      expect(accounts.any((a) => a.name == 'Account 2'), isTrue);
    });

    test('Update mnemonic', () async {
      // Create a mnemonic
      final mnemonicId = await mnemonicRepo.createNewMnemonic(
        name: 'Original Name',
        mnemonic: 'test test test test test test test test test test test junk',
        passphrase: 'test_passphrase',
        masterKey: 'test_master_key',
      );

      // Get the mnemonic
      final mnemonic = await mnemonicRepo.getMnemonicById(mnemonicId);
      expect(mnemonic!.name, equals('Original Name'));

      // Update the mnemonic
      final updatedMnemonic = mnemonic.copyWith(name: 'Updated Name');
      await mnemonicRepo.updateMnemonicWithTimestamp(updatedMnemonic);

      // Verify the update
      final updatedMnemonicFromDb = await mnemonicRepo.getMnemonicById(
        mnemonicId,
      );
      expect(updatedMnemonicFromDb!.name, equals('Updated Name'));
    });

    test('Delete operations', () async {
      // Create test data
      final mnemonicId = await mnemonicRepo.createNewMnemonic(
        name: 'Test Wallet',
        mnemonic: 'test test test test test test test test test test test junk',
        passphrase: 'test_passphrase',
        masterKey: 'test_master_key',
      );

      final accountId = await accountRepo.createNewAccount(
        mnemonicId: mnemonicId,
        name: 'Test Account',
        address: 'cosmos1test123...',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/118'/0'/0/0",
      );

      final endpointId = await endpointRepo.createNewEndpoint(
        name: 'Test Endpoint',
        url: 'https://test-rpc.example.com',
        chanId: 'test-chain-1',
      );

      final balanceId = await balanceRepo.createNewBalance(
        accountId: accountId,
        endpointId: endpointId,
        balance: '1000000uatom',
      );

      // Verify data exists
      expect(await mnemonicRepo.getMnemonicById(mnemonicId), isNotNull);
      expect(await accountRepo.getAccountById(accountId), isNotNull);
      expect(await endpointRepo.getEndpointById(endpointId), isNotNull);
      expect(await balanceRepo.getBalanceById(balanceId), isNotNull);

      // Delete operations
      await balanceRepo.deleteBalance(balanceId);
      await accountRepo.deleteAccount(accountId);
      await endpointRepo.deleteEndpoint(endpointId);
      await mnemonicRepo.deleteMnemonic(mnemonicId);

      // Verify data is deleted
      expect(await mnemonicRepo.getMnemonicById(mnemonicId), isNull);
      expect(await accountRepo.getAccountById(accountId), isNull);
      expect(await endpointRepo.getEndpointById(endpointId), isNull);
      expect(await balanceRepo.getBalanceById(balanceId), isNull);
    });
  });
}
