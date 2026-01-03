import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Ride.dart';
import '../services/ride_service.dart';
import 'ride_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final RideApiService _rideService = RideApiService();
  List<Ride> _bookedRides = [];
  bool _isLoading = true;
  String? _error;

  // Temporary: hardcoded until auth
  static const int _currentPassengerId = 1;

  @override
  void initState() {
    super.initState();
    _fetchBookedRides();
  }

  Future<void> _fetchBookedRides() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rides = await _rideService.getMyBookedRides(_currentPassengerId);
      setState(() {
        _bookedRides = rides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _fetchBookedRides, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_bookedRides.isEmpty) {
      return const Center(
        child: Text('You have no booked rides.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookedRides,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookedRides.length,
        itemBuilder: (context, index) {
          final ride = _bookedRides[index];
          final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('${ride.origin.name} -> ${ride.destination.name}'),
              subtitle: Text(dateFormat.format(ride.departureTime)),
              trailing: Chip(
                label: Text(ride.rideStatus.name),
                backgroundColor: ride.rideStatus == RideStatus.OPEN
                    ? Colors.green[100]
                    : Colors.grey[200],
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideDetailsScreen(ride: ride),
                  ),
                );
                _fetchBookedRides();
              },
            ),
          );
        },
      ),
    );
  }
}
