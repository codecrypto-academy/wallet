import 'package:bdd_lib/bdd_lib.dart';

void main() async {
  // Inicializar la base de datos
  final dbHelper = DatabaseHelper();

  // Ejemplo: Crear un mnemonic
  final mnemonic = Mnemonic(
    name: 'Mi Wallet',
    mnemonic:
        'word1 word2 word3 word4 word5 word6 word7 word8 word9 word10 word11 word12',
    passphrase: 'mi-passphrase',
    masterKey: 'master-key-example',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // Insertar el mnemonic
  final mnemonicId = await dbHelper.insertMnemonic(mnemonic);
  print('Mnemonic insertado con ID: $mnemonicId');

  // Crear un endpoint
  final endpoint = Endpoint(
    name: 'Ethereum Mainnet',
    url: 'https://mainnet.infura.io/v3/YOUR-PROJECT-ID',
    chainId: '1',
    createdAt: DateTime.now(),
  );

  // Insertar el endpoint
  final endpointId = await dbHelper.insertEndpoint(endpoint);
  print('Endpoint insertado con ID: $endpointId');

  // Crear una cuenta
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
  print('Cuenta insertada con ID: $accountId');

  // Crear un balance
  final balance = Balance(
    accountId: accountId,
    endpointId: endpointId,
    balance: '1.5',
    createdAt: DateTime.now(),
  );

  // Insertar el balance
  final balanceId = await dbHelper.insertBalance(balance);
  print('Balance insertado con ID: $balanceId');

  // Crear una transacción
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
  print('Transacción insertada con ID: $txId');

  // Consultar todos los mnemonics
  final allMnemonics = await dbHelper.getAllMnemonics();
  print('Total de mnemonics: ${allMnemonics.length}');

  // Consultar todas las cuentas
  final allAccounts = await dbHelper.getAllAccounts();
  print('Total de cuentas: ${allAccounts.length}');

  // Consultar balances por cuenta
  final accountBalances = await dbHelper.getBalancesByAccount(accountId);
  print('Balances de la cuenta $accountId: ${accountBalances.length}');

  // Consultar transacciones por cuenta
  final accountTransactions = await dbHelper.getTransactionsByAccount(
    accountId,
  );
  print('Transacciones de la cuenta $accountId: ${accountTransactions.length}');

  // Cerrar la base de datos
  await dbHelper.close();
  print('Base de datos cerrada');
}
