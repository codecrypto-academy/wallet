import '../database/database_helper.dart';
import '../models/balance.dart';

class BalanceRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Create
  Future<int> createBalance(Balance balance) async {
    return await _databaseHelper.insertBalance(balance);
  }

  // Read
  Future<List<Balance>> getAllBalances() async {
    return await _databaseHelper.getAllBalances();
  }

  Future<Balance?> getBalanceById(int id) async {
    return await _databaseHelper.getBalance(id);
  }

  Future<List<Balance>> getBalancesByAccountId(int accountId) async {
    return await _databaseHelper.getBalancesByAccountId(accountId);
  }

  Future<List<Balance>> getBalancesByEndpointId(int endpointId) async {
    return await _databaseHelper.getBalancesByEndpointId(endpointId);
  }

  // Update
  Future<int> updateBalance(Balance balance) async {
    return await _databaseHelper.updateBalance(balance);
  }

  // Delete
  Future<int> deleteBalance(int id) async {
    return await _databaseHelper.deleteBalance(id);
  }

  // Helper method to create a new balance with current timestamp
  Future<int> createNewBalance({
    required int accountId,
    required int endpointId,
    required String balance,
  }) async {
    final newBalance = Balance(
      accountId: accountId,
      endpointId: endpointId,
      balance: balance,
      createdAt: DateTime.now(),
    );
    return await createBalance(newBalance);
  }

  // Get balance with account and endpoint details
  Future<List<Map<String, dynamic>>> getBalanceWithDetails(
    int balanceId,
  ) async {
    return await _databaseHelper.getBalanceWithDetails(balanceId);
  }

  // Get all balances with account and endpoint details
  Future<List<Map<String, dynamic>>> getAllBalancesWithDetails() async {
    return await _databaseHelper.getAllBalancesWithDetails();
  }

  /// Delete all balances from the database
  Future<int> deleteAllBalances() async {
    return await _databaseHelper.deleteAllBalances();
  }
}
