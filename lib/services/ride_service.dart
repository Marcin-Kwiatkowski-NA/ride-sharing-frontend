import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Ride.dart';

class RideApiService {
  static const String baseUrl =
      'http://ow0wk84w4sogcgs8g0s488wg.130.61.31.172.sslip.io';

  Future<List<Ride>> searchRides({
    String? origin,
    String? destination,
    DateTime? departureDate,
    int minSeats = 1,
    int page = 0,
    int size = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'minSeats': minSeats.toString(),
    };

    if (origin != null && origin.isNotEmpty) queryParams['origin'] = origin;
    if (destination != null && destination.isNotEmpty) {
      queryParams['destination'] = destination;
    }
    if (departureDate != null) {
      queryParams['departureDate'] =
          departureDate.toIso8601String().split('T')[0];
    }

    final uri =
        Uri.parse('$baseUrl/rides/search').replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> content = data['content'] ?? [];
      return content.map((json) => Ride.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search rides: ${response.statusCode}');
    }
  }

  Future<List<Ride>> getAllRides({int page = 0, int size = 10}) async {
    final uri = Uri.parse('$baseUrl/rides')
        .replace(queryParameters: {'page': page.toString(), 'size': size.toString()});

    final response = await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> content = data['content'] ?? [];
      return content.map((json) => Ride.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get rides: ${response.statusCode}');
    }
  }

  Future<Ride> getRideById(int rideId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rides/$rideId'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Ride.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get ride: ${response.statusCode}');
    }
  }

  Future<Ride> bookRide(int rideId, int passengerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/book?passengerId=$passengerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Ride.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to book ride');
    }
  }

  Future<Ride> cancelBooking(int rideId, int passengerId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/rides/$rideId/book?passengerId=$passengerId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Ride.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Failed to cancel booking');
    }
  }

  Future<List<Ride>> getMyBookedRides(int passengerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/travelers/$passengerId/rides'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Ride.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get booked rides: ${response.statusCode}');
    }
  }
}
