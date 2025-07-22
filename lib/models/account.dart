class Account {
  final int? id;
  final int mnemonicId;
  final String name;
  final String address;
  final String privateKey;
  final int derivationIndex;
  final String derivationPath;
  final DateTime createdAt;

  Account({
    this.id,
    required this.mnemonicId,
    required this.name,
    required this.address,
    required this.privateKey,
    required this.derivationIndex,
    required this.derivationPath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mnemonicId': mnemonicId,
      'name': name,
      'address': address,
      'privateKey': privateKey,
      'derivationIndex': derivationIndex,
      'derivationPath': derivationPath,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      mnemonicId: map['mnemonicId'],
      name: map['name'],
      address: map['address'],
      privateKey: map['privateKey'],
      derivationIndex: map['derivationIndex'],
      derivationPath:
          map['derivationPath'] ?? "m/44'/60'/0'/0/${map['derivationIndex']}",
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, name: $name, address: ${address.substring(0, 8)}..., derivationIndex: $derivationIndex, derivationPath: $derivationPath)';
  }
}
