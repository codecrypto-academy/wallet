class Tx {
  final int? id;
  final int accountId;
  final int endpointId;
  final int nonce;
  final String fromAccount;
  final String toAccount;
  final int amount;
  final DateTime createdAt;

  Tx({
    this.id,
    required this.accountId,
    required this.endpointId,
    required this.nonce,
    required this.fromAccount,
    required this.toAccount,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'endpointId': endpointId,
      'nonce': nonce,
      'fromAccount': fromAccount,
      'toAccount': toAccount,
      'amount': amount,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Tx.fromMap(Map<String, dynamic> map) {
    return Tx(
      id: map['id'],
      accountId: map['accountId'],
      endpointId: map['endpointId'],
      nonce: map['nonce'],
      fromAccount: map['fromAccount'],
      toAccount: map['toAccount'],
      amount: map['amount'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
} 