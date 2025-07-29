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

  // Create from Map (for database operations)
  factory Mnemonic.fromMap(Map<String, dynamic> map) {
    return Mnemonic(
      id: map['id'] as int?,
      name: map['name'] as String,
      mnemonic: map['mnemonic'] as String,
      passphrase: map['passphrase'] as String,
      masterKey: map['master_key'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // Convert to Map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mnemonic': mnemonic,
      'passphrase': passphrase,
      'master_key': masterKey,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  Mnemonic copyWith({
    int? id,
    String? name,
    String? mnemonic,
    String? passphrase,
    String? masterKey,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Mnemonic(
      id: id ?? this.id,
      name: name ?? this.name,
      mnemonic: mnemonic ?? this.mnemonic,
      passphrase: passphrase ?? this.passphrase,
      masterKey: masterKey ?? this.masterKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Mnemonic(id: $id, name: $name, mnemonic: $mnemonic, passphrase: $passphrase, masterKey: $masterKey, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mnemonic &&
        other.id == id &&
        other.name == name &&
        other.mnemonic == mnemonic &&
        other.passphrase == passphrase &&
        other.masterKey == masterKey &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        mnemonic.hashCode ^
        passphrase.hashCode ^
        masterKey.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
