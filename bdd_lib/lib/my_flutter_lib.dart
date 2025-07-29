// Export all models
export 'models/account.dart';
export 'models/mnemonic.dart';
export 'models/endpoint.dart';
export 'models/balance.dart';

// Export database helper
export 'database/database_helper.dart';

// Export all repositories
export 'repositories/mnemonic_repository.dart';
export 'repositories/account_repository.dart';
export 'repositories/endpoint_repository.dart';
export 'repositories/balance_repository.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}
