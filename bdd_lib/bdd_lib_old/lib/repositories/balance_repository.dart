import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import '../database_helper.dart';

class BalanceRepository {
  final DatabaseHelper _dbHelper;

  BalanceRepository(this._dbHelper);

  Future<int> insert(Balance balance) async {
    final db = await _dbHelper.database;
    return await db.insert('balances', balance.toMap());
  }

  Future<List<Balance>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('balances');
    return List.generate(maps.length, (i) => Balance.fromMap(maps[i]));
  }

  Future<List<Balance>> getByAccountId(int accountId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'balances',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    return List.generate(maps.length, (i) => Balance.fromMap(maps[i]));
  }

  Future<Balance?> getById(int id) async {
    final db = await _dbHelper.database;
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

  Future<int> update(Balance balance) async {
    final db = await _dbHelper.database;
    return await db.update(
      'balances',
      balance.toMap(),
      where: 'id = ?',
      whereArgs: [balance.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'balances',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 