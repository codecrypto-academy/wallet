import 'package:bdd_lib/bdd_lib.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  print('🚀 Iniciando ejemplo de BDD Library...');

  try {
    // Inicializar SQLite para consola
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // Inicializar la base de datos
    final dbHelper = DatabaseHelper();
    print('✅ Base de datos inicializada');

    // Crear un mnemonic de ejemplo
    final mnemonic = Mnemonic(
      name: 'Mi Wallet de Prueba',
      mnemonic: 'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12',
      passphrase: 'mi-passphrase-secreta',
      masterKey: 'master-key-de-prueba',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Insertar el mnemonic
    final mnemonicId = await dbHelper.insertMnemonic(mnemonic);
    print('✅ Mnemonic insertado con ID: $mnemonicId');

    // Crear un endpoint de ejemplo
    final endpoint = Endpoint(
      name: 'Ethereum Mainnet',
      url: 'https://mainnet.infura.io/v3/YOUR-PROJECT-ID',
      chainId: '1',
      createdAt: DateTime.now(),
    );

    // Insertar el endpoint
    final endpointId = await dbHelper.insertEndpoint(endpoint);
    print('✅ Endpoint insertado con ID: $endpointId');

    // Crear una cuenta de ejemplo
    final account = Account(
      mnemonicId: mnemonicId,
      name: 'Cuenta Principal',
      address: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      derivationIndex: 0,
      derivationPathPattern: "m/44'/60'/0'/0/0",
      createdAt: DateTime.now(),
    );

    // Insertar la cuenta
    final accountId = await dbHelper.insertAccount(account);
    print('✅ Cuenta insertada con ID: $accountId');

    // Crear un balance de ejemplo
    final balance = Balance(
      accountId: accountId,
      endpointId: endpointId,
      balance: '2.5',
      createdAt: DateTime.now(),
    );

    // Insertar el balance
    final balanceId = await dbHelper.insertBalance(balance);
    print('✅ Balance insertado con ID: $balanceId');

    // Crear una transacción de ejemplo
    final transaction = Tx(
      accountId: accountId,
      endpointId: endpointId,
      nonce: 0,
      fromAccount: '0x742d35Cc6634C0532925a3b8D4C9db96C4b4d8b6',
      toAccount: '0x1234567890123456789012345678901234567890',
      amount: 1000000000000000000, // 1 ETH en wei
      createdAt: DateTime.now(),
    );

    // Insertar la transacción
    final txId = await dbHelper.insertTx(transaction);
    print('✅ Transacción insertada con ID: $txId');

    // Consultar todos los datos
    final allMnemonics = await dbHelper.getAllMnemonics();
    final allEndpoints = await dbHelper.getAllEndpoints();
    final allAccounts = await dbHelper.getAllAccounts();
    final allBalances = await dbHelper.getAllBalances();
    final allTransactions = await dbHelper.getAllTransactions();

    print('\n📊 Resumen de datos:');
    print('   • Mnemonics: ${allMnemonics.length}');
    print('   • Endpoints: ${allEndpoints.length}');
    print('   • Cuentas: ${allAccounts.length}');
    print('   • Balances: ${allBalances.length}');
    print('   • Transacciones: ${allTransactions.length}');

    // Mostrar detalles del primer mnemonic
    if (allMnemonics.isNotEmpty) {
      final firstMnemonic = allMnemonics.first;
      print('\n🔍 Detalles del primer mnemonic:');
      print('   • ID: ${firstMnemonic.id}');
      print('   • Nombre: ${firstMnemonic.name}');
      print('   • Mnemonic: ${firstMnemonic.mnemonic.substring(0, 20)}...');
      print('   • Creado: ${firstMnemonic.createdAt}');
    }

    // Mostrar cuentas por mnemonic
    final accountsByMnemonic = await dbHelper.getAccountsByMnemonic(mnemonicId);
    print('\n👤 Cuentas del mnemonic $mnemonicId: ${accountsByMnemonic.length}');

    // Mostrar balances por cuenta
    final balancesByAccount = await dbHelper.getBalancesByAccount(accountId);
    print('💰 Balances de la cuenta $accountId: ${balancesByAccount.length}');

    // Mostrar transacciones por cuenta
    final transactionsByAccount = await dbHelper.getTransactionsByAccount(accountId);
    print('📝 Transacciones de la cuenta $accountId: ${transactionsByAccount.length}');

    // Cerrar la base de datos
    await dbHelper.close();
    print('\n✅ Base de datos cerrada correctamente');
    print('🎉 ¡Ejemplo completado exitosamente!');
  } catch (e) {
    print('❌ Error durante la ejecución: $e');
  }
} 