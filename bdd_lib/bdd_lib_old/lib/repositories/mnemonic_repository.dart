import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import '../database_helper.dart';

class MnemonicRepository {
  final DatabaseHelper _dbHelper;

  MnemonicRepository(this._dbHelper);

  Future<int> insert(Mnemonic mnemonic) async {
    final db = await _dbHelper.database;
    return await db.insert('mnemonics', mnemonic.toMap());
  }

  Future<List<Mnemonic>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('mnemonics');
    return List.generate(maps.length, (i) => Mnemonic.fromMap(maps[i]));
  }

  Future<Mnemonic?> getById(int id) async {
    final db = await _dbHelper.database;
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

  Future<int> update(Mnemonic mnemonic) async {
    final db = await _dbHelper.database;
    return await db.update(
      'mnemonics',
      mnemonic.toMap(),
      where: 'id = ?',
      whereArgs: [mnemonic.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'mnemonics',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 