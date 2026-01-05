class City {
  final String name;
  final int osmId;

  City({required this.name, required this.osmId});

  factory City.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'];
    return City(
      name: properties['name'] ?? 'Unknown City',
      osmId: properties['osm_id'],
    );
  }

  factory City.fromStorageJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? 'Unknown City',
      osmId: json['osmId'],
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'name': name,
      'osmId': osmId,
    };
  }

  String get displayName {
    return '$name, $osmId';
  }
}