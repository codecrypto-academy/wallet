import 'package:sqflite/sqflite.dart';
import '../models/models.dart';
import '../database_helper.dart';

class EndpointRepository {
  final DatabaseHelper _dbHelper;

  EndpointRepository(this._dbHelper);

  Future<int> insert(Endpoint endpoint) async {
    final db = await _dbHelper.database;
    return await db.insert('endpoints', endpoint.toMap());
  }

  Future<List<Endpoint>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('endpoints');
    return List.generate(maps.length, (i) => Endpoint.fromMap(maps[i]));
  }

  Future<Endpoint?> getById(int id) async {
    final db = await _dbHelper.database;
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

  Future<int> update(Endpoint endpoint) async {
    final db = await _dbHelper.database;
    return await db.update(
      'endpoints',
      endpoint.toMap(),
      where: 'id = ?',
      whereArgs: [endpoint.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'endpoints',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 