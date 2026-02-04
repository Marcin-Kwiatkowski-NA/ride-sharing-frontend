import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

@freezed
sealed class Vehicle with _$Vehicle {
  const factory Vehicle({
    required int id,
    String? make,
    String? model,
    int? productionYear,
    String? color,
    String? licensePlate,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
}
