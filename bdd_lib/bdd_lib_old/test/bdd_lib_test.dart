import 'package:flutter_test/flutter_test.dart';
import 'package:bdd_lib/bdd_lib.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('BDD Library Tests', () {
    late DatabaseHelper dbHelper;

    setUpAll(() async {
      // Inicializar SQLite para tests
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      dbHelper = DatabaseHelper();
      // Esperar a que la base de datos se inicialice
      await dbHelper.database;
    });

    tearDown(() async {
      // No cerrar la base de datos en cada test para evitar problemas
      // La base de datos se cerrará automáticamente al final
    });

    tearDownAll(() async {
      // Cerrar la base de datos solo al final de todos los tests
      try {
        await dbHelper.close();
      } catch (e) {
        // Ignorar errores de cierre
      }
    });

    test('should create and retrieve mnemonic', () async {
      // Arrange
      final mnemonic = Mnemonic(
        name: 'Test Wallet',
        mnemonic:
            'test word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12',
        passphrase: 'test-passphrase',
        masterKey: 'test-master-key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final id = await dbHelper.insertMnemonic(mnemonic);
      final retrievedMnemonic = await dbHelper.getMnemonic(id);

      // Assert
      expect(id, isNotNull);
      expect(retrievedMnemonic, isNotNull);
      expect(retrievedMnemonic!.name, equals('Test Wallet'));
      expect(
        retrievedMnemonic.mnemonic,
        equals(
          'test word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12',
        ),
      );
    });

    test('should create and retrieve endpoint', () async {
      // Arrange
      final endpoint = Endpoint(
        name: 'Test Endpoint',
        url: 'https://test.example.com',
        chainId: '1',
        createdAt: DateTime.now(),
      );

      // Act
      final id = await dbHelper.insertEndpoint(endpoint);
      final retrievedEndpoint = await dbHelper.getEndpoint(id);

      // Assert
      expect(id, isNotNull);
      expect(retrievedEndpoint, isNotNull);
      expect(retrievedEndpoint!.name, equals('Test Endpoint'));
      expect(retrievedEndpoint.url, equals('https://test.example.com'));
    });

    test('should create account with mnemonic relationship', () async {
      // Arrange
      final mnemonic = Mnemonic(
        name: 'Test Wallet',
        mnemonic: 'test words',
        passphrase: 'test-passphrase',
        masterKey: 'test-master-key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final mnemonicId = await dbHelper.insertMnemonic(mnemonic);

      final account = Account(
        mnemonicId: mnemonicId,
        name: 'Test Account',
        address: '0x1234567890123456789012345678901234567890',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/60'/0'/0/0",
        createdAt: DateTime.now(),
      );

      // Act
      final accountId = await dbHelper.insertAccount(account);
      final retrievedAccount = await dbHelper.getAccount(accountId);
      final accountsByMnemonic = await dbHelper.getAccountsByMnemonic(
        mnemonicId,
      );

      // Assert
      expect(accountId, isNotNull);
      expect(retrievedAccount, isNotNull);
      expect(retrievedAccount!.name, equals('Test Account'));
      expect(accountsByMnemonic.length, equals(1));
      expect(accountsByMnemonic.first.id, equals(accountId));
    });

    test(
      'should create balance with account and endpoint relationships',
      () async {
        // Arrange
        final mnemonic = Mnemonic(
          name: 'Test Wallet',
          mnemonic: 'test words',
          passphrase: 'test-passphrase',
          masterKey: 'test-master-key',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final endpoint = Endpoint(
          name: 'Test Endpoint',
          url: 'https://test.example.com',
          chainId: '1',
          createdAt: DateTime.now(),
        );

        final mnemonicId = await dbHelper.insertMnemonic(mnemonic);
        final endpointId = await dbHelper.insertEndpoint(endpoint);

        final account = Account(
          mnemonicId: mnemonicId,
          name: 'Test Account',
          address: '0x1234567890123456789012345678901234567890',
          derivationIndex: 0,
          derivationPathPattern: "m/44'/60'/0'/0/0",
          createdAt: DateTime.now(),
        );

        final accountId = await dbHelper.insertAccount(account);

        final balance = Balance(
          accountId: accountId,
          endpointId: endpointId,
          balance: '1.5',
          createdAt: DateTime.now(),
        );

        // Act
        final balanceId = await dbHelper.insertBalance(balance);
        final retrievedBalance = await dbHelper.getBalance(balanceId);
        final balancesByAccount = await dbHelper.getBalancesByAccount(
          accountId,
        );

        // Assert
        expect(balanceId, isNotNull);
        expect(retrievedBalance, isNotNull);
        expect(retrievedBalance!.balance, equals('1.5'));
        expect(balancesByAccount.length, equals(1));
        expect(balancesByAccount.first.id, equals(balanceId));
      },
    );

    test('should create transaction with relationships', () async {
      // Arrange
      final mnemonic = Mnemonic(
        name: 'Test Wallet',
        mnemonic: 'test words',
        passphrase: 'test-passphrase',
        masterKey: 'test-master-key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final endpoint = Endpoint(
        name: 'Test Endpoint',
        url: 'https://test.example.com',
        chainId: '1',
        createdAt: DateTime.now(),
      );

      final mnemonicId = await dbHelper.insertMnemonic(mnemonic);
      final endpointId = await dbHelper.insertEndpoint(endpoint);

      final account = Account(
        mnemonicId: mnemonicId,
        name: 'Test Account',
        address: '0x1234567890123456789012345678901234567890',
        derivationIndex: 0,
        derivationPathPattern: "m/44'/60'/0'/0/0",
        createdAt: DateTime.now(),
      );

      final accountId = await dbHelper.insertAccount(account);

      final transaction = Tx(
        accountId: accountId,
        endpointId: endpointId,
        nonce: 0,
        fromAccount: '0x1234567890123456789012345678901234567890',
        toAccount: '0x0987654321098765432109876543210987654321',
        amount: 1000000000000000000,
        createdAt: DateTime.now(),
      );

      // Act
      final txId = await dbHelper.insertTx(transaction);
      final retrievedTx = await dbHelper.getTransaction(txId);
      final transactionsByAccount = await dbHelper.getTransactionsByAccount(
        accountId,
      );

      // Assert
      expect(txId, isNotNull);
      expect(retrievedTx, isNotNull);
      expect(retrievedTx!.nonce, equals(0));
      expect(retrievedTx.amount, equals(1000000000000000000));
      expect(transactionsByAccount.length, equals(1));
      expect(transactionsByAccount.first.id, equals(txId));
    });

    test('should update mnemonic', () async {
      // Arrange
      final mnemonic = Mnemonic(
        name: 'Original Name',
        mnemonic: 'test words',
        passphrase: 'test-passphrase',
        masterKey: 'test-master-key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await dbHelper.insertMnemonic(mnemonic);

      final updatedMnemonic = Mnemonic(
        id: id,
        name: 'Updated Name',
        mnemonic: mnemonic.mnemonic,
        passphrase: mnemonic.passphrase,
        masterKey: mnemonic.masterKey,
        createdAt: mnemonic.createdAt,
        updatedAt: DateTime.now(),
      );

      // Act
      await dbHelper.updateMnemonic(updatedMnemonic);
      final retrievedMnemonic = await dbHelper.getMnemonic(id);

      // Assert
      expect(retrievedMnemonic!.name, equals('Updated Name'));
    });

    test('should delete mnemonic', () async {
      // Arrange
      final mnemonic = Mnemonic(
        name: 'Test Wallet',
        mnemonic: 'test words',
        passphrase: 'test-passphrase',
        masterKey: 'test-master-key',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await dbHelper.insertMnemonic(mnemonic);

      // Act
      await dbHelper.deleteMnemonic(id);
      final retrievedMnemonic = await dbHelper.getMnemonic(id);

      // Assert
      expect(retrievedMnemonic, isNull);
    });
  });
}
