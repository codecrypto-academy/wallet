class Mnemonic {
  final int? id;
  final String name;
  final String mnemonic;
  final String passphrase;
  final String masterKey;
  final DateTime createdAt;
  final DateTime updatedAt;

  Mnemonic({
    this.id,
    required this.name,
    required this.mnemonic,
    required this.passphrase,
    required this.masterKey,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mnemonic': mnemonic,
      'passphrase': passphrase,
      'masterKey': masterKey,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Mnemonic.fromMap(Map<String, dynamic> map) {
    return Mnemonic(
      id: map['id'],
      name: map['name'],
      mnemonic: map['mnemonic'],
      passphrase: map['passphrase'],
      masterKey: map['masterKey'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
} 