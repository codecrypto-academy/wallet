import 'package:flutter/material.dart';
import '../models/mnemonic.dart';
import '../services/database_service.dart';

class MnemonicProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Mnemonic> _mnemonics = [];
  bool _isLoading = false;
  String? _error;

  List<Mnemonic> get mnemonics => _mnemonics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar todos los mnemonics
  Future<void> loadMnemonics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Cargando mnemonics...');
      _mnemonics = await _databaseService.getMnemonics();
      debugPrint('Mnemonics cargados: ${_mnemonics.length}');
    } catch (e) {
      debugPrint('Error loading mnemonics: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar un nuevo mnemonic
  Future<void> addMnemonic(Mnemonic mnemonic) async {
    try {
      debugPrint('Agregando mnemonic: ${mnemonic.name}');
      final id = await _databaseService.insertMnemonic(mnemonic);
      final newMnemonic = Mnemonic(
        id: id,
        mnemonic: mnemonic.mnemonic,
        password: mnemonic.password,
        name: mnemonic.name,
        createdAt: mnemonic.createdAt,
      );
      _mnemonics.insert(0, newMnemonic); // Insertar al inicio
      debugPrint('Mnemonic agregado con ID: $id');
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding mnemonic: $e');
      rethrow;
    }
  }

  // Actualizar un mnemonic
  Future<void> updateMnemonic(Mnemonic mnemonic) async {
    try {
      debugPrint('Actualizando mnemonic: ${mnemonic.name}');
      await _databaseService.updateMnemonic(mnemonic);
      final index = _mnemonics.indexWhere((m) => m.id == mnemonic.id);
      if (index != -1) {
        _mnemonics[index] = mnemonic;
        notifyListeners();
        debugPrint('Mnemonic actualizado');
      }
    } catch (e) {
      debugPrint('Error updating mnemonic: $e');
      rethrow;
    }
  }

  // Eliminar un mnemonic
  Future<void> deleteMnemonic(int id) async {
    try {
      debugPrint('Eliminando mnemonic con ID: $id');
      await _databaseService.deleteMnemonic(id);
      _mnemonics.removeWhere((m) => m.id == id);
      notifyListeners();
      debugPrint('Mnemonic eliminado');
    } catch (e) {
      debugPrint('Error deleting mnemonic: $e');
      rethrow;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
