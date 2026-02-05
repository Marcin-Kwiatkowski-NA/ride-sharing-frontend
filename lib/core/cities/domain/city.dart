import 'package:freezed_annotation/freezed_annotation.dart';

part 'city.freezed.dart';
part 'city.g.dart';

@freezed
sealed class City with _$City {
  const City._();

  const factory City({
    required String name,
    required int placeId,
    String? countryCode,
    int? population,
  }) = _City;

  /// Parse from Photon API response feature
  factory City.fromPhotonJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>;
    return City(
      name: properties['name'] as String? ?? 'Unknown',
      placeId: properties['geonameid'] as int,
      countryCode: properties['country_code'] as String?,
      population: properties['population'] as int?,
    );
  }

  /// Parse from local storage (v2 format with placeId)
  factory City.fromStorageJson(Map<String, dynamic> json) => City(
        name: json['name'] as String,
        placeId: json['placeId'] as int,
        countryCode: json['countryCode'] as String?,
        population: json['population'] as int?,
      );

  /// Serialize for local storage
  Map<String, dynamic> toStorageJson() => {
        'name': name,
        'placeId': placeId,
        'countryCode': countryCode,
        'population': population,
      };

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
}
