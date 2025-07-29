import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/models.dart';
import 'repositories/repositories.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Repositorios
  late final MnemonicRepository mnemonics;
  late final EndpointRepository endpoints;
  late final AccountRepository accounts;
  late final BalanceRepository balances;
  late final TransactionRepository transactions;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    // Inicializar repositorios
    mnemonics = MnemonicRepository(this);
    endpoints = EndpointRepository(this);
    accounts = AccountRepository(this);
    balances = BalanceRepository(this);
    transactions = TransactionRepository(this);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bdd_lib.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla Mnemonic
    await db.execute('''
      CREATE TABLE mnemonics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        mnemonic TEXT NOT NULL,
        passphrase TEXT NOT NULL,
        masterKey TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Crear tabla Endpoint
    await db.execute('''
      CREATE TABLE endpoints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        chainId TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Crear tabla Account
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mnemonicId INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        derivationIndex INTEGER NOT NULL,
        derivationPathPattern TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (mnemonicId) REFERENCES mnemonics (id)
      )
    ''');

    // Crear tabla Balance
    await db.execute('''
      CREATE TABLE balances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER NOT NULL,
        endpointId INTEGER NOT NULL,
        balance TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id),
        FOREIGN KEY (endpointId) REFERENCES endpoints (id)
      )
    ''');

    // Crear tabla Tx
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountId INTEGER NOT NULL,
        endpointId INTEGER NOT NULL,
        nonce INTEGER NOT NULL,
        fromAccount TEXT NOT NULL,
        toAccount TEXT NOT NULL,
        amount INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (accountId) REFERENCES accounts (id),
        FOREIGN KEY (endpointId) REFERENCES endpoints (id)
      )
    ''');
  }

  // Métodos para Mnemonic (API de compatibilidad)
  Future<int> insertMnemonic(Mnemonic mnemonic) async {
    return await mnemonics.insert(mnemonic);
  }

  Future<List<Mnemonic>> getAllMnemonics() async {
    return await mnemonics.getAll();
  }

  Future<Mnemonic?> getMnemonic(int id) async {
    return await mnemonics.getById(id);
  }

  Future<int> updateMnemonic(Mnemonic mnemonic) async {
    return await mnemonics.update(mnemonic);
  }

  Future<int> deleteMnemonic(int id) async {
    return await mnemonics.delete(id);
  }

  // Métodos para Endpoint (API de compatibilidad)
  Future<int> insertEndpoint(Endpoint endpoint) async {
    return await endpoints.insert(endpoint);
  }

  Future<List<Endpoint>> getAllEndpoints() async {
    return await endpoints.getAll();
  }

  Future<Endpoint?> getEndpoint(int id) async {
    return await endpoints.getById(id);
  }

  Future<int> updateEndpoint(Endpoint endpoint) async {
    return await endpoints.update(endpoint);
  }

  Future<int> deleteEndpoint(int id) async {
    return await endpoints.delete(id);
  }

  // Métodos para Account (API de compatibilidad)
  Future<int> insertAccount(Account account) async {
    return await accounts.insert(account);
  }

  Future<List<Account>> getAllAccounts() async {
    return await accounts.getAll();
  }

  Future<List<Account>> getAccountsByMnemonic(int mnemonicId) async {
    return await accounts.getByMnemonicId(mnemonicId);
  }

  Future<Account?> getAccount(int id) async {
    return await accounts.getById(id);
  }

  Future<int> updateAccount(Account account) async {
    return await accounts.update(account);
  }

  Future<int> deleteAccount(int id) async {
    return await accounts.delete(id);
  }

  // Métodos para Balance (API de compatibilidad)
  Future<int> insertBalance(Balance balance) async {
    return await balances.insert(balance);
  }

  Future<List<Balance>> getAllBalances() async {
    return await balances.getAll();
  }

  Future<List<Balance>> getBalancesByAccount(int accountId) async {
    return await balances.getByAccountId(accountId);
  }

  Future<Balance?> getBalance(int id) async {
    return await balances.getById(id);
  }

  Future<int> updateBalance(Balance balance) async {
    return await balances.update(balance);
  }

  Future<int> deleteBalance(int id) async {
    return await balances.delete(id);
  }

  // Métodos para Tx (API de compatibilidad)
  Future<int> insertTx(Tx tx) async {
    return await transactions.insert(tx);
  }

  Future<List<Tx>> getAllTransactions() async {
    return await transactions.getAll();
  }

  Future<List<Tx>> getTransactionsByAccount(int accountId) async {
    return await transactions.getByAccountId(accountId);
  }

  Future<Tx?> getTransaction(int id) async {
    return await transactions.getById(id);
  }

  Future<int> updateTransaction(Tx tx) async {
    return await transactions.update(tx);
  }

  Future<int> deleteTransaction(int id) async {
    return await transactions.delete(id);
  }

  // Método para cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
