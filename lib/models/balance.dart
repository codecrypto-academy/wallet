class Balance {
  final int id;
  final int mnemonicId;
  final int accountId;
  final int endpointId;
  final String balance;
  final String symbol;
  final DateTime lastUpdated;

  Balance({
    required this.id,
    required this.mnemonicId,
    required this.accountId,
    required this.endpointId,
    required this.balance,
    required this.symbol,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mnemonicId': mnemonicId,
      'accountId': accountId,
      'endpointId': endpointId,
      'balance': balance,
      'symbol': symbol,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory Balance.fromMap(Map<String, dynamic> map) {
    return Balance(
      id: map['id'],
      mnemonicId: map['mnemonicId'],
      accountId: map['accountId'],
      endpointId: map['endpointId'],
      balance: map['balance'],
      symbol: map['symbol'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }
}
