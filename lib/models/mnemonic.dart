class Mnemonic {
  final int? id;
  final String mnemonic;
  final String password;
  final String name;
  final DateTime createdAt;

  Mnemonic({
    this.id,
    required this.mnemonic,
    required this.password,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mnemonic': mnemonic,
      'password': password,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Mnemonic.fromMap(Map<String, dynamic> map) {
    return Mnemonic(
      id: map['id'],
      mnemonic: map['mnemonic'],
      password: map['password'],
      name: map['name'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  @override
  String toString() {
    return 'Mnemonic(id: $id, name: $name, mnemonic: ${mnemonic.substring(0, 10)}..., createdAt: $createdAt)';
  }
}
