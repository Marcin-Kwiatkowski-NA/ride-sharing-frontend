import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/location_ref_dto.dart';

part 'location.freezed.dart';
part 'location.g.dart';

/// Domain model for a geographic location, identified by OSM ID.
///
/// Carries full Photon/OSM data including coordinates, geographic hierarchy,
/// and OSM metadata.
@freezed
sealed class Location with _$Location {
  const Location._();

  const factory Location({
    required int osmId,
    required String name,
    required double latitude,
    required double longitude,
    String? countryCode,
    String? country,
    String? state,
    String? county,
    String? city,
    String? postCode,
    String? type,
    String? osmKey,
    String? osmValue,
  }) = _Location;

  /// Parse from Photon API GeoJSON feature.
  ///
  /// Photon returns features with `properties` (metadata) and
  /// `geometry.coordinates` as [longitude, latitude] (GeoJSON standard).
  factory Location.fromPhotonFeature(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List<dynamic>;
    // GeoJSON: [lon, lat]
    final lon = (coordinates[0] as num).toDouble();
    final lat = (coordinates[1] as num).toDouble();

    return Location(
      osmId: properties['osm_id'] as int,
      name: properties['name'] as String? ?? 'Unknown',
      latitude: lat,
      longitude: lon,
      countryCode: properties['countrycode'] as String?,
      country: properties['country'] as String?,
      state: properties['state'] as String?,
      county: properties['county'] as String?,
      city: properties['city'] as String?,
      postCode: properties['postcode'] as String?,
      type: properties['type'] as String?,
      osmKey: properties['osm_key'] as String?,
      osmValue: properties['osm_value'] as String?,
    );
  }

  /// Parse from SharedPreferences storage.
  factory Location.fromStorageJson(Map<String, dynamic> json) => Location(
        osmId: json['osmId'] as int,
        name: json['name'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        countryCode: json['countryCode'] as String?,
        country: json['country'] as String?,
        state: json['state'] as String?,
        county: json['county'] as String?,
        city: json['city'] as String?,
        postCode: json['postCode'] as String?,
        type: json['type'] as String?,
        osmKey: json['osmKey'] as String?,
        osmValue: json['osmValue'] as String?,
      );

  /// Serialize for SharedPreferences storage.
  Map<String, dynamic> toStorageJson() => {
        'osmId': osmId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        if (countryCode != null) 'countryCode': countryCode,
        if (country != null) 'country': country,
        if (state != null) 'state': state,
        if (county != null) 'county': county,
        if (city != null) 'city': city,
        if (postCode != null) 'postCode': postCode,
        if (type != null) 'type': type,
        if (osmKey != null) 'osmKey': osmKey,
        if (osmValue != null) 'osmValue': osmValue,
      };

  /// Convert to strongly-typed LocationRefDto for API requests.
  ///
  /// [lang] indicates which language [name] is in (`"pl"` or `"en"`),
  /// so the backend knows which name field to populate directly
  /// and which to resolve via reverse geocoding.
  LocationRefDto toLocationRefDto({required String lang}) => LocationRefDto(
        osmId: osmId,
        name: name,
        lang: lang,
        latitude: latitude,
        longitude: longitude,
        countryCode: countryCode,
        country: country,
        state: state,
        county: county,
        city: city,
        postCode: postCode,
        type: type,
        osmKey: osmKey,
        osmValue: osmValue,
      );

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
