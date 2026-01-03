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

  String get displayName {
    return '$name, $osmId';
  }
}