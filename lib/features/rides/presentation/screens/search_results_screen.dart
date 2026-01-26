import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/Ride.dart';
import '../../../../services/ride_service.dart';
import 'ride_details_screen_legacy.dart';

class SearchResultsScreen extends StatefulWidget {
  final String? origin;
  final String? destination;
  final DateTime? departureDate;
  final TimeOfDay? departureTimeFrom;

  const SearchResultsScreen({
    super.key,
    this.origin,
    this.destination,
    this.departureDate,
    this.departureTimeFrom,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final RideApiService _rideService = RideApiService();
  List<Ride> _rides = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final rides = await _rideService.searchRides(
        origin: widget.origin,
        destination: widget.destination,
        departureDate: widget.departureDate,
        departureTimeFrom: widget.departureTimeFrom,
      );
      setState(() {
        _rides = rides;
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
        title: const Text('Search Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchRides,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_rides.isEmpty) {
      return const Center(
        child: Text('No rides found matching your criteria.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRides,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rides.length,
        itemBuilder: (context, index) => _buildRideCard(_rides[index]),
      ),
    );
  }

  Widget _buildRideCard(Ride ride) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideDetailsScreenLegacy(ride: ride),
            ),
          );
          _fetchRides();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trip_origin,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(ride.origin.name,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.flag,
                      color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(ride.destination.name,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(dateFormat.format(ride.departureTime)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(timeFormat.format(ride.departureTime)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event_seat, size: 16),
                      const SizedBox(width: 4),
                      Text('${ride.availableSeats} seats'),
                    ],
                  ),
                  Text(
                    ride.pricePerSeat != null
                        ? '${ride.pricePerSeat!.toStringAsFixed(2)} PLN'
                        : 'Ask driver',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
