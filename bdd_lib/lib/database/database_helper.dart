import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/account.dart';
import '../models/mnemonic.dart';
import '../models/endpoint.dart';
import '../models/balance.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_flutter_lib.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create mnemonics table
    await db.execute('''
      CREATE TABLE mnemonics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        mnemonic TEXT NOT NULL,
        passphrase TEXT NOT NULL,
        master_key TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mnemonic_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        derivation_index INTEGER NOT NULL,
        derivation_path_pattern TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (mnemonic_id) REFERENCES mnemonics (id) ON DELETE CASCADE
      )
    ''');

    // Create endpoints table
    await db.execute('''
      CREATE TABLE endpoints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        url TEXT NOT NULL,
        chan_id TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create balances table
    await db.execute('''
      CREATE TABLE balances (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        endpoint_id INTEGER NOT NULL,
        balance TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (endpoint_id) REFERENCES endpoints (id) ON DELETE CASCADE
      )
    ''');
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // ==================== MNEMONIC CRUD OPERATIONS ====================

  Future<int> insertMnemonic(Mnemonic mnemonic) async {
    final db = await database;
    return await db.insert('mnemonics', mnemonic.toMap());
  }

  Future<List<Mnemonic>> getAllMnemonics() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('mnemonics');
    return List.generate(maps.length, (i) => Mnemonic.fromMap(maps[i]));
  }

  Future<Mnemonic?> getMnemonic(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mnemonics',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Mnemonic.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateMnemonic(Mnemonic mnemonic) async {
    final db = await database;
    return await db.update(
      'mnemonics',
      mnemonic.toMap(),
      where: 'id = ?',
      whereArgs: [mnemonic.id],
    );
  }

  Future<int> deleteMnemonic(int id) async {
    final db = await database;
    return await db.delete('mnemonics', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ACCOUNT CRUD OPERATIONS ====================

  Future<int> insertAccount(Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<List<Account>> getAccountsByMnemonicId(int mnemonicId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'mnemonic_id = ?',
      whereArgs: [mnemonicId],
    );
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<Account?> getAccount(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAccount(Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ENDPOINT CRUD OPERATIONS ====================

  Future<int> insertEndpoint(Endpoint endpoint) async {
    final db = await database;
    return await db.insert('endpoints', endpoint.toMap());
  }

  Future<List<Endpoint>> getAllEndpoints() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('endpoints');
    return List.generate(maps.length, (i) => Endpoint.fromMap(maps[i]));
  }

  Future<Endpoint?> getEndpoint(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'endpoints',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Endpoint.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateEndpoint(Endpoint endpoint) async {
    final db = await database;
    return await db.update(
      'endpoints',
      endpoint.toMap(),
      where: 'id = ?',
      whereArgs: [endpoint.id],
    );
  }

  Future<int> deleteEndpoint(int id) async {
    final db = await database;
    return await db.delete('endpoints', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== BALANCE CRUD OPERATIONS ====================

  Future<int> insertBalance(Balance balance) async {
    final db = await database;
    return await db.insert('balances', balance.toMap());
  }

  Future<int> deleteAllBalances() async {
    final db = await database;
    return await db.delete('balances');
  }

  Future<List<Balance>> getAllBalances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('balances');
    return List.generate(maps.length, (i) => Balance.fromMap(maps[i]));
  }

  Future<List<Balance>> getBalancesByAccountId(int accountId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'balances',
      where: 'account_id = ?',
      whereArgs: [accountId],
    );
    return List.generate(maps.length, (i) => Balance.fromMap(maps[i]));
  }

  Future<List<Balance>> getBalancesByEndpointId(int endpointId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'balances',
      where: 'endpoint_id = ?',
      whereArgs: [endpointId],
    );
    return List.generate(maps.length, (i) => Balance.fromMap(maps[i]));
  }

  Future<Balance?> getBalance(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'balances',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Balance.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBalance(Balance balance) async {
    final db = await database;
    return await db.update(
      'balances',
      balance.toMap(),
      where: 'id = ?',
      whereArgs: [balance.id],
    );
  }

  Future<int> deleteBalance(int id) async {
    final db = await database;
    return await db.delete('balances', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ADVANCED QUERIES ====================

  Future<List<Map<String, dynamic>>> getAccountWithMnemonic(
    int accountId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        a.*,
        m.name as mnemonic_name,
        m.mnemonic
      FROM accounts a
      INNER JOIN mnemonics m ON a.mnemonic_id = m.id
      WHERE a.id = ?
    ''',
      [accountId],
    );
  }

  Future<List<Map<String, dynamic>>> getBalanceWithDetails(
    int balanceId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT 
        b.*,
        a.name as account_name,
        a.address,
        e.name as endpoint_name,
        e.url
      FROM balances b
      INNER JOIN accounts a ON b.account_id = a.id
      INNER JOIN endpoints e ON b.endpoint_id = e.id
      WHERE b.id = ?
    ''',
      [balanceId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllBalancesWithDetails() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        b.*,
        a.name as account_name,
        a.address,
        e.name as endpoint_name,
        e.url
      FROM balances b
      INNER JOIN accounts a ON b.account_id = a.id
      INNER JOIN endpoints e ON b.endpoint_id = e.id
      ORDER BY b.created_at DESC
    ''');
  }
}
