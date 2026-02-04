import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_stats.freezed.dart';
part 'user_stats.g.dart';

/// Converts num (int or double from JSON) to double.
double _numToDouble(num value) => value.toDouble();

@freezed
sealed class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int ridesGiven,
    @Default(0) int ridesTaken,
    @Default(0.0) @JsonKey(fromJson: _numToDouble) double ratingAvg,
    @Default(0) int ratingCount,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}
