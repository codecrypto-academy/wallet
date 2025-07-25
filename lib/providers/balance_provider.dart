import 'package:flutter/foundation.dart';
import '../models/balance.dart';
import '../services/database_service.dart';
import '../services/balance_service.dart';

class BalanceProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final BalanceService _balanceService = BalanceService();
  List<Balance> _balances = [];
  bool _isLoading = false;
  String? _error;

  List<Balance> get balances => _balances;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadBalances() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Cargando balances...');
      _balances = await _databaseService.getBalances();
      debugPrint('Balances cargados: ${_balances.length}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando balances: $e');
      _error = 'Error cargando balances: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBalancesByAccount(int accountId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Cargando balances para cuenta $accountId...');
      _balances = await _databaseService.getBalancesByAccount(accountId);
      debugPrint(
        'Balances cargados para cuenta $accountId: ${_balances.length}',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando balances por cuenta: $e');
      _error = 'Error cargando balances: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBalancesByMnemonic(int mnemonicId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Cargando balances para mnemonic $mnemonicId...');
      _balances = await _databaseService.getBalancesByMnemonic(mnemonicId);
      debugPrint(
        'Balances cargados para mnemonic $mnemonicId: ${_balances.length}',
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error cargando balances por mnemonic: $e');
      _error = 'Error cargando balances: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBalance(Balance balance) async {
    try {
      debugPrint('Agregando balance...');
      final id = await _databaseService.insertBalance(balance);
      final newBalance = Balance(
        id: id,
        mnemonicId: balance.mnemonicId,
        accountId: balance.accountId,
        endpointId: balance.endpointId,
        balance: balance.balance,
        symbol: balance.symbol,
        lastUpdated: balance.lastUpdated,
      );

      _balances.insert(0, newBalance);
      notifyListeners();
      debugPrint('Balance agregado con ID: $id');
    } catch (e) {
      debugPrint('Error agregando balance: $e');
      _error = 'Error agregando balance: $e';
      notifyListeners();
    }
  }

  Future<void> updateBalance(Balance balance) async {
    try {
      debugPrint('Actualizando balance ${balance.id}...');
      await _databaseService.updateBalance(balance);

      final index = _balances.indexWhere((b) => b.id == balance.id);
      if (index != -1) {
        _balances[index] = balance;
        notifyListeners();
      }
      debugPrint('Balance actualizado');
    } catch (e) {
      debugPrint('Error actualizando balance: $e');
      _error = 'Error actualizando balance: $e';
      notifyListeners();
    }
  }

  Future<void> deleteBalance(int id) async {
    try {
      debugPrint('Eliminando balance $id...');
      await _databaseService.deleteBalance(id);

      _balances.removeWhere((balance) => balance.id == id);
      notifyListeners();
      debugPrint('Balance eliminado');
    } catch (e) {
      debugPrint('Error eliminando balance: $e');
      _error = 'Error eliminando balance: $e';
      notifyListeners();
    }
  }

  /// Actualiza todos los balances consultando los endpoints de Ethereum
  Future<void> updateAllBalancesFromEndpoints() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Iniciando actualización masiva de balances...');
      await _balanceService.updateAllBalances();

      // Recargar los balances después de la actualización
      await loadBalances();

      debugPrint('Actualización masiva completada');
    } catch (e) {
      debugPrint('Error en actualización masiva: $e');
      _error = 'Error actualizando balances: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el balance de una cuenta específica en un endpoint específico
  Future<void> updateBalanceForAccount(int accountId, int endpointId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint(
        'Actualizando balance para cuenta $accountId en endpoint $endpointId...',
      );
      await _balanceService.updateBalanceForAccount(accountId, endpointId);

      // Recargar los balances después de la actualización
      await loadBalances();

      debugPrint('Balance actualizado exitosamente');
    } catch (e) {
      debugPrint('Error actualizando balance específico: $e');
      _error = 'Error actualizando balance: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
