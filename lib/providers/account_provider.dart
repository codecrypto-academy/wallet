import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/database_service.dart';

class AccountProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Account> _accounts = [];
  bool _isLoading = false;
  String? _error;

  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar todas las cuentas
  Future<void> loadAccounts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Cargando accounts...');
      _accounts = await _databaseService.getAccounts();
      debugPrint('Accounts cargadas: ${_accounts.length}');
    } catch (e) {
      debugPrint('Error loading accounts: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar cuentas por mnemonic
  Future<void> loadAccountsByMnemonic(int mnemonicId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('Cargando accounts para mnemonic $mnemonicId...');
      _accounts = await _databaseService.getAccountsByMnemonic(mnemonicId);
      debugPrint(
        'Accounts cargadas para mnemonic $mnemonicId: ${_accounts.length}',
      );
    } catch (e) {
      debugPrint('Error loading accounts by mnemonic: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar una nueva cuenta
  Future<void> addAccount(Account account) async {
    try {
      debugPrint('Agregando account: ${account.name}');
      final id = await _databaseService.insertAccount(account);
      final newAccount = Account(
        id: id,
        mnemonicId: account.mnemonicId,
        name: account.name,
        address: account.address,
        privateKey: account.privateKey,
        derivationIndex: account.derivationIndex,
        derivationPath: account.derivationPath,
        createdAt: account.createdAt,
      );
      _accounts.insert(0, newAccount); // Insertar al inicio
      debugPrint('Account agregada con ID: $id');
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding account: $e');
      rethrow;
    }
  }

  // Actualizar una cuenta
  Future<void> updateAccount(Account account) async {
    try {
      debugPrint('Actualizando account: ${account.name}');
      await _databaseService.updateAccount(account);
      final index = _accounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _accounts[index] = account;
        notifyListeners();
        debugPrint('Account actualizada');
      }
    } catch (e) {
      debugPrint('Error updating account: $e');
      rethrow;
    }
  }

  // Eliminar una cuenta
  Future<void> deleteAccount(int id) async {
    try {
      debugPrint('Eliminando account con ID: $id');
      await _databaseService.deleteAccount(id);
      _accounts.removeWhere((a) => a.id == id);
      notifyListeners();
      debugPrint('Account eliminada');
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  // Obtener el siguiente índice de derivación
  Future<int> getNextDerivationIndex(int mnemonicId) async {
    try {
      return await _databaseService.getNextDerivationIndex(mnemonicId);
    } catch (e) {
      debugPrint('Error getting next derivation index: $e');
      return 0;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
