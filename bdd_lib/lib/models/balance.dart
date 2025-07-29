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

  // Create from Map (for database operations)
  factory Balance.fromMap(Map<String, dynamic> map) {
    return Balance(
      id: map['id'] as int?,
      accountId: map['account_id'] as int,
      endpointId: map['endpoint_id'] as int,
      balance: map['balance'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to Map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'endpoint_id': endpointId,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  Balance copyWith({
    int? id,
    int? accountId,
    int? endpointId,
    String? balance,
    DateTime? createdAt,
  }) {
    return Balance(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      endpointId: endpointId ?? this.endpointId,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Balance(id: $id, accountId: $accountId, endpointId: $endpointId, balance: $balance, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Balance &&
        other.id == id &&
        other.accountId == accountId &&
        other.endpointId == endpointId &&
        other.balance == balance &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        accountId.hashCode ^
        endpointId.hashCode ^
        balance.hashCode ^
        createdAt.hashCode;
  }
}
