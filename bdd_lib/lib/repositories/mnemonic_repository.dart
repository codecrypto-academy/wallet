import '../database/database_helper.dart';
import '../models/mnemonic.dart';

class MnemonicRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Create
  Future<int> createMnemonic(Mnemonic mnemonic) async {
    return await _databaseHelper.insertMnemonic(mnemonic);
  }

  // Read
  Future<List<Mnemonic>> getAllMnemonics() async {
    return await _databaseHelper.getAllMnemonics();
  }

  Future<Mnemonic?> getMnemonicById(int id) async {
    return await _databaseHelper.getMnemonic(id);
  }

  // Update
  Future<int> updateMnemonic(Mnemonic mnemonic) async {
    return await _databaseHelper.updateMnemonic(mnemonic);
  }

  // Delete
  Future<int> deleteMnemonic(int id) async {
    return await _databaseHelper.deleteMnemonic(id);
  }

  // Helper method to create a new mnemonic with current timestamps
  Future<int> createNewMnemonic({
    required String name,
    required String mnemonic,
    required String passphrase,
    required String masterKey,
  }) async {
    final now = DateTime.now();
    final newMnemonic = Mnemonic(
      name: name,
      mnemonic: mnemonic,
      passphrase: passphrase,
      masterKey: masterKey,
      createdAt: now,
      updatedAt: now,
    );
    return await createMnemonic(newMnemonic);
  }

  // Helper method to update mnemonic with new updated timestamp
  Future<int> updateMnemonicWithTimestamp(Mnemonic mnemonic) async {
    final updatedMnemonic = mnemonic.copyWith(updatedAt: DateTime.now());
    return await updateMnemonic(updatedMnemonic);
  }
}
