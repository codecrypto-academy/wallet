class Account {
  final int? id;
  final int mnemonicId;
  final String name;
  final String address;
  final int derivationIndex;
  final String derivationPathPattern;
  final DateTime createdAt;

  Account({
    this.id,
    required this.mnemonicId,
    required this.name,
    required this.address,
    required this.derivationIndex,
    required this.derivationPathPattern,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mnemonicId': mnemonicId,
      'name': name,
      'address': address,
      'derivationIndex': derivationIndex,
      'derivationPathPattern': derivationPathPattern,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      mnemonicId: map['mnemonicId'],
      name: map['name'],
      address: map['address'],
      derivationIndex: map['derivationIndex'],
      derivationPathPattern: map['derivationPathPattern'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
} 