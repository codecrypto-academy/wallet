class Endpoint {
  final int? id;
  final String name;
  final String url;
  final String chanId;

  Endpoint({
    this.id,
    required this.name,
    required this.url,
    required this.chanId,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'url': url, 'chanId': chanId};
  }

  factory Endpoint.fromMap(Map<String, dynamic> map) {
    return Endpoint(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      chanId: map['chanId'],
    );
  }

  @override
  String toString() {
    return 'Endpoint(id: $id, name: $name, url: $url, chanId: $chanId)';
  }
}
