class Balance {
  final int? id;
  final int accountId;
  final int endpointId;
  final String balance;
  final DateTime createdAt;

  Balance({
    this.id,
    required this.accountId,
    required this.endpointId,
    required this.balance,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'endpointId': endpointId,
      'balance': balance,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Balance.fromMap(Map<String, dynamic> map) {
    return Balance(
      id: map['id'],
      accountId: map['accountId'],
      endpointId: map['endpointId'],
      balance: map['balance'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}
