class Endpoint {
  final int? id;
  final String name;
  final String url;
  final String chainId;
  final DateTime createdAt;

  Endpoint({
    this.id,
    required this.name,
    required this.url,
    required this.chainId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'chainId': chainId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Endpoint.fromMap(Map<String, dynamic> map) {
    return Endpoint(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      chainId: map['chainId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
} 