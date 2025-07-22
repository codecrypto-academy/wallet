class Transaction {
  final int? id;
  final int accountId;
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String txHash;
  final String status;
  final DateTime createdAt;

  Transaction({
    this.id,
    required this.accountId,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.txHash,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountId': accountId,
      'fromAddress': fromAddress,
      'toAddress': toAddress,
      'amount': amount,
      'txHash': txHash,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      accountId: map['accountId'],
      fromAddress: map['fromAddress'],
      toAddress: map['toAddress'],
      amount: map['amount'],
      txHash: map['txHash'],
      status: map['status'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, from: ${fromAddress.substring(0, 8)}..., to: ${toAddress.substring(0, 8)}..., amount: $amount, status: $status)';
  }
}
