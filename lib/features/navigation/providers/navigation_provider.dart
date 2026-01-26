import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Provider for the current navigation tab index
/// 0 = Rides, 1 = Passengers, 2 = Profile
final navigationIndexProvider = StateProvider<int>((ref) => 0);
