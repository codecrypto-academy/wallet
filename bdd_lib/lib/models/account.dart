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

  // Create from Map (for database operations)
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int?,
      mnemonicId: map['mnemonic_id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      derivationIndex: map['derivation_index'] as int,
      derivationPathPattern: map['derivation_path_pattern'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to Map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mnemonic_id': mnemonicId,
      'name': name,
      'address': address,
      'derivation_index': derivationIndex,
      'derivation_path_pattern': derivationPathPattern,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  Account copyWith({
    int? id,
    int? mnemonicId,
    String? name,
    String? address,
    int? derivationIndex,
    String? derivationPathPattern,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      mnemonicId: mnemonicId ?? this.mnemonicId,
      name: name ?? this.name,
      address: address ?? this.address,
      derivationIndex: derivationIndex ?? this.derivationIndex,
      derivationPathPattern:
          derivationPathPattern ?? this.derivationPathPattern,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, mnemonicId: $mnemonicId, name: $name, address: $address, derivationIndex: $derivationIndex, derivationPathPattern: $derivationPathPattern, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.mnemonicId == mnemonicId &&
        other.name == name &&
        other.address == address &&
        other.derivationIndex == derivationIndex &&
        other.derivationPathPattern == derivationPathPattern &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        mnemonicId.hashCode ^
        name.hashCode ^
        address.hashCode ^
        derivationIndex.hashCode ^
        derivationPathPattern.hashCode ^
        createdAt.hashCode;
  }
}
