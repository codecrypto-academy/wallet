import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';
import '../models/endpoint.dart';
import '../models/mnemonic.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static sqflite.Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<sqflite.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sqflite.Database> _initDatabase() async {
    try {
      String path = join(await sqflite.getDatabasesPath(), 'endpoints.db');
      debugPrint('Inicializando base de datos en: $path');

      return await sqflite.openDatabase(
        path,
        version: 5,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      debugPrint('Error inicializando base de datos: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(sqflite.Database db, int version) async {
    try {
      debugPrint('Creando tablas de base de datos...');

      // Tabla endpoints
      await db.execute('''
        CREATE TABLE endpoints(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          url TEXT NOT NULL,
          chanId TEXT NOT NULL
        )
      ''');
      debugPrint('Tabla endpoints creada');

      // Tabla mnemonics
      await db.execute('''
        CREATE TABLE mnemonics(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mnemonic TEXT NOT NULL,
          password TEXT NOT NULL,
          name TEXT NOT NULL,
          createdAt INTEGER NOT NULL
        )
      ''');
      debugPrint('Tabla mnemonics creada');

      // Tabla accounts
      await db.execute('''
        CREATE TABLE accounts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          mnemonicId INTEGER NOT NULL,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          privateKey TEXT NOT NULL,
          derivationIndex INTEGER NOT NULL,
          derivationPath TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (mnemonicId) REFERENCES mnemonics (id) ON DELETE CASCADE
        )
      ''');
      debugPrint('Tabla accounts creada');

      // Tabla transactions
      await db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          accountId INTEGER NOT NULL,
          fromAddress TEXT NOT NULL,
          toAddress TEXT NOT NULL,
          amount TEXT NOT NULL,
          txHash TEXT NOT NULL,
          status TEXT NOT NULL,
          createdAt INTEGER NOT NULL,
          FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE CASCADE
        )
      ''');
      debugPrint('Tabla transactions creada');
    } catch (e) {
      debugPrint('Error creando tablas: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(
    sqflite.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      debugPrint(
        'Actualizando base de datos de versión $oldVersion a $newVersion',
      );

      if (oldVersion < 2) {
        // Agregar tabla mnemonics si no existe
        await db.execute('''
          CREATE TABLE IF NOT EXISTS mnemonics(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mnemonic TEXT NOT NULL,
            password TEXT NOT NULL,
            name TEXT NOT NULL,
            createdAt INTEGER NOT NULL
          )
        ''');
        debugPrint('Tabla mnemonics agregada en upgrade');
      }

      if (oldVersion < 3) {
        // Agregar tabla accounts si no existe
        await db.execute('''
          CREATE TABLE IF NOT EXISTS accounts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mnemonicId INTEGER NOT NULL,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            privateKey TEXT NOT NULL,
            derivationIndex INTEGER NOT NULL,
            derivationPath TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            FOREIGN KEY (mnemonicId) REFERENCES mnemonics (id) ON DELETE CASCADE
          )
        ''');
        debugPrint('Tabla accounts agregada en upgrade');
      }

      if (oldVersion < 4) {
        // Agregar tabla transactions si no existe
        await db.execute('''
          CREATE TABLE IF NOT EXISTS transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            accountId INTEGER NOT NULL,
            fromAddress TEXT NOT NULL,
            toAddress TEXT NOT NULL,
            amount TEXT NOT NULL,
            txHash TEXT NOT NULL,
            status TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            FOREIGN KEY (accountId) REFERENCES accounts (id) ON DELETE CASCADE
          )
        ''');
        debugPrint('Tabla transactions agregada en upgrade');
      }

      if (oldVersion < 5) {
        // Agregar columna derivationPath a la tabla accounts
        await db.execute('ALTER TABLE accounts ADD COLUMN derivationPath TEXT');

        // Actualizar registros existentes con el path por defecto
        await db.execute('''
          UPDATE accounts 
          SET derivationPath = 'm/44''/60''/0''/0/' || derivationIndex 
          WHERE derivationPath IS NULL
        ''');
        debugPrint('Columna derivationPath agregada a tabla accounts');
      }
    } catch (e) {
      debugPrint('Error en upgrade de base de datos: $e');
      rethrow;
    }
  }

  // ========== ENDPOINTS OPERATIONS ==========

  // Insertar un nuevo endpoint
  Future<int> insertEndpoint(Endpoint endpoint) async {
    try {
      final db = await database;
      final id = await db.insert('endpoints', endpoint.toMap());
      debugPrint('Endpoint insertado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error insertando endpoint: $e');
      rethrow;
    }
  }

  // Obtener todos los endpoints
  Future<List<Endpoint>> getEndpoints() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('endpoints');
      final endpoints = List.generate(
        maps.length,
        (i) => Endpoint.fromMap(maps[i]),
      );
      debugPrint('Endpoints obtenidos: ${endpoints.length}');
      return endpoints;
    } catch (e) {
      debugPrint('Error obteniendo endpoints: $e');
      rethrow;
    }
  }

  // Actualizar un endpoint
  Future<int> updateEndpoint(Endpoint endpoint) async {
    try {
      final db = await database;
      final result = await db.update(
        'endpoints',
        endpoint.toMap(),
        where: 'id = ?',
        whereArgs: [endpoint.id],
      );
      debugPrint('Endpoint actualizado: $result filas afectadas');
      return result;
    } catch (e) {
      debugPrint('Error actualizando endpoint: $e');
      rethrow;
    }
  }

  // Eliminar un endpoint
  Future<int> deleteEndpoint(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'endpoints',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Endpoint eliminado: $result filas afectadas');
      return result;
    } catch (e) {
      debugPrint('Error eliminando endpoint: $e');
      rethrow;
    }
  }

  // ========== MNEMONICS OPERATIONS ==========

  // Insertar un nuevo mnemonic
  Future<int> insertMnemonic(Mnemonic mnemonic) async {
    try {
      final db = await database;
      final id = await db.insert('mnemonics', mnemonic.toMap());
      debugPrint('Mnemonic insertado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error insertando mnemonic: $e');
      rethrow;
    }
  }

  // Obtener todos los mnemonics
  Future<List<Mnemonic>> getMnemonics() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'mnemonics',
        orderBy: 'createdAt DESC',
      );
      final mnemonics = List.generate(
        maps.length,
        (i) => Mnemonic.fromMap(maps[i]),
      );
      debugPrint('Mnemonics obtenidos: ${mnemonics.length}');
      return mnemonics;
    } catch (e) {
      debugPrint('Error obteniendo mnemonics: $e');
      rethrow;
    }
  }

  // Actualizar un mnemonic
  Future<int> updateMnemonic(Mnemonic mnemonic) async {
    try {
      final db = await database;
      final result = await db.update(
        'mnemonics',
        mnemonic.toMap(),
        where: 'id = ?',
        whereArgs: [mnemonic.id],
      );
      debugPrint('Mnemonic actualizado: $result filas afectadas');
      return result;
    } catch (e) {
      debugPrint('Error actualizando mnemonic: $e');
      rethrow;
    }
  }

  // Eliminar un mnemonic
  Future<int> deleteMnemonic(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'mnemonics',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Mnemonic eliminado: $result filas afectadas');
      return result;
    } catch (e) {
      debugPrint('Error eliminando mnemonic: $e');
      rethrow;
    }
  }

  // ========== ACCOUNTS OPERATIONS ==========

  // Insertar una nueva cuenta
  Future<int> insertAccount(Account account) async {
    try {
      final db = await database;
      final id = await db.insert('accounts', account.toMap());
      debugPrint('Account insertada con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error insertando account: $e');
      rethrow;
    }
  }

  // Obtener todas las cuentas
  Future<List<Account>> getAccounts() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'accounts',
        orderBy: 'createdAt DESC',
      );
      final accounts = List.generate(
        maps.length,
        (i) => Account.fromMap(maps[i]),
      );
      debugPrint('Accounts obtenidas: ${accounts.length}');
      return accounts;
    } catch (e) {
      debugPrint('Error obteniendo accounts: $e');
      rethrow;
    }
  }

  // Obtener cuentas por mnemonic
  Future<List<Account>> getAccountsByMnemonic(int mnemonicId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'accounts',
        where: 'mnemonicId = ?',
        whereArgs: [mnemonicId],
        orderBy: 'derivationIndex ASC',
      );
      final accounts = List.generate(
        maps.length,
        (i) => Account.fromMap(maps[i]),
      );
      debugPrint(
        'Accounts obtenidas para mnemonic $mnemonicId: ${accounts.length}',
      );
      return accounts;
    } catch (e) {
      debugPrint('Error obteniendo accounts por mnemonic: $e');
      rethrow;
    }
  }

  // Actualizar una cuenta
  Future<int> updateAccount(Account account) async {
    try {
      final db = await database;
      final result = await db.update(
        'accounts',
        account.toMap(),
        where: 'id = ?',
        whereArgs: [account.id],
      );
      debugPrint('Account actualizada: $result filas afectadas');
      return result;
    } catch (e) {
      debugPrint('Error actualizando account: $e');
      rethrow;
    }
  }

  // Eliminar una cuenta
  Future<int> deleteAccount(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'accounts',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Account eliminada: $result filas afectadas');
      return result;
    } catch (e) {
      debugPrint('Error eliminando account: $e');
      rethrow;
    }
  }

  // Obtener el siguiente índice de derivación para un mnemonic
  Future<int> getNextDerivationIndex(int mnemonicId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'accounts',
        where: 'mnemonicId = ?',
        whereArgs: [mnemonicId],
        orderBy: 'derivationIndex DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return 0;
      }

      final lastIndex = maps.first['derivationIndex'] as int;
      return lastIndex + 1;
    } catch (e) {
      debugPrint('Error obteniendo siguiente índice de derivación: $e');
      return 0;
    }
  }

  // ========== TRANSACTIONS OPERATIONS ==========

  // Insertar una nueva transacción
  Future<int> insertTransaction(Transaction transaction) async {
    try {
      final db = await database;
      final id = await db.insert('transactions', transaction.toMap());
      debugPrint('Transaction insertada con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error insertando transaction: $e');
      rethrow;
    }
  }

  // Obtener todas las transacciones
  Future<List<Transaction>> getTransactions() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        orderBy: 'createdAt DESC',
      );
      final transactions = List.generate(
        maps.length,
        (i) => Transaction.fromMap(maps[i]),
      );
      debugPrint('Transactions obtenidas: ${transactions.length}');
      return transactions;
    } catch (e) {
      debugPrint('Error obteniendo transactions: $e');
      rethrow;
    }
  }

  // Obtener transacciones por cuenta
  Future<List<Transaction>> getTransactionsByAccount(int accountId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'transactions',
        where: 'accountId = ?',
        whereArgs: [accountId],
        orderBy: 'createdAt DESC',
      );
      final transactions = List.generate(
        maps.length,
        (i) => Transaction.fromMap(maps[i]),
      );
      debugPrint(
        'Transactions obtenidas para account $accountId: ${transactions.length}',
      );
      return transactions;
    } catch (e) {
      debugPrint('Error obteniendo transactions por account: $e');
      rethrow;
    }
  }

  // Actualizar una transacción
  Future<int> updateTransaction(Transaction transaction) async {
    try {
      final db = await database;
      final result = await db.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      debugPrint('Transaction actualizada: $result filas afectadas');
      return result;
    } catch (e) {
      debugPrint('Error actualizando transaction: $e');
      rethrow;
    }
  }

  // Eliminar una transacción
  Future<int> deleteTransaction(int id) async {
    try {
      final db = await database;
      final result = await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Transaction eliminada: $result filas afectadas');
      return result;
    } catch (e) {
      debugPrint('Error eliminando transaction: $e');
      rethrow;
    }
  }

  // Cerrar la base de datos
  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      debugPrint('Base de datos cerrada');
    } catch (e) {
      debugPrint('Error cerrando base de datos: $e');
      rethrow;
    }
  }
}
