import '../database/database_helper.dart';
import '../models/account.dart';

class AccountRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Create
  Future<int> createAccount(Account account) async {
    return await _databaseHelper.insertAccount(account);
  }

  // Read
  Future<List<Account>> getAllAccounts() async {
    return await _databaseHelper.getAllAccounts();
  }

  Future<Account?> getAccountById(int id) async {
    return await _databaseHelper.getAccount(id);
  }

  Future<List<Account>> getAccountsByMnemonicId(int mnemonicId) async {
    return await _databaseHelper.getAccountsByMnemonicId(mnemonicId);
  }

  // Update
  Future<int> updateAccount(Account account) async {
    return await _databaseHelper.updateAccount(account);
  }

  // Delete
  Future<int> deleteAccount(int id) async {
    return await _databaseHelper.deleteAccount(id);
  }

  // Helper method to create a new account with current timestamp
  Future<int> createNewAccount({
    required int mnemonicId,
    required String name,
    required String address,
    required int derivationIndex,
    required String derivationPathPattern,
  }) async {
    final newAccount = Account(
      mnemonicId: mnemonicId,
      name: name,
      address: address,
      derivationIndex: derivationIndex,
      derivationPathPattern: derivationPathPattern,
      createdAt: DateTime.now(),
    );
    return await createAccount(newAccount);
  }

  // Get account with mnemonic details
  Future<List<Map<String, dynamic>>> getAccountWithMnemonic(
    int accountId,
  ) async {
    return await _databaseHelper.getAccountWithMnemonic(accountId);
  }
}
