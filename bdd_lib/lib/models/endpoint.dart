class Endpoint {
  final int? id;
  final String name;
  final String url;
  final String chanId;
  final DateTime createdAt;

  Endpoint({
    this.id,
    required this.name,
    required this.url,
    required this.chanId,
    required this.createdAt,
  });

  // Create from Map (for database operations)
  factory Endpoint.fromMap(Map<String, dynamic> map) {
    return Endpoint(
      id: map['id'] as int?,
      name: map['name'] as String,
      url: map['url'] as String,
      chanId: map['chan_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  // Convert to Map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'chan_id': chanId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a copy with updated fields
  Endpoint copyWith({
    int? id,
    String? name,
    String? url,
    String? chanId,
    DateTime? createdAt,
  }) {
    return Endpoint(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      chanId: chanId ?? this.chanId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Endpoint(id: $id, name: $name, url: $url, chanId: $chanId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Endpoint &&
        other.id == id &&
        other.name == name &&
        other.url == url &&
        other.chanId == chanId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        url.hashCode ^
        chanId.hashCode ^
        createdAt.hashCode;
  }
}
