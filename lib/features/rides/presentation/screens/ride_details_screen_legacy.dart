import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/Ride.dart';
import '../../../../services/ride_service.dart';

class RideDetailsScreenLegacy extends StatefulWidget {
  final Ride ride;

  const RideDetailsScreenLegacy({super.key, required this.ride});

  @override
  State<RideDetailsScreenLegacy> createState() => _RideDetailsScreenLegacyState();
}

class _RideDetailsScreenLegacyState extends State<RideDetailsScreenLegacy> {
  final RideApiService _rideService = RideApiService();
  late Ride _ride;
  bool _isBooking = false;

  // Temporary: hardcoded passenger ID until auth is implemented
  static const int _currentPassengerId = 1;

  @override
  void initState() {
    super.initState();
    _ride = widget.ride;
  }

  bool get _isAlreadyBooked {
    return _ride.passengers.any((p) => p.id == _currentPassengerId);
  }

  bool get _canBook {
    return _ride.rideStatus == RideStatus.OPEN &&
        _ride.availableSeats > 0 &&
        !_isAlreadyBooked;
  }

  Future<void> _bookRide() async {
    setState(() => _isBooking = true);

    try {
      final updatedRide =
          await _rideService.bookRide(_ride.id!, _currentPassengerId);
      setState(() {
        _ride = updatedRide;
        _isBooking = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ride booked successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() => _isBooking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel your booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isBooking = true);

    try {
      final updatedRide =
          await _rideService.cancelBooking(_ride.id!, _currentPassengerId);
      setState(() {
        _ride = updatedRide;
        _isBooking = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled.')),
        );
      }
    } catch (e) {
      setState(() => _isBooking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Route Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildRouteRow(
                      icon: Icons.trip_origin,
                      label: 'From',
                      value: _ride.origin.name,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    _buildRouteRow(
                      icon: Icons.flag,
                      label: 'To',
                      value: _ride.destination.name,
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time and Date Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today, 'Date',
                        dateFormat.format(_ride.departureTime)),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.access_time, 'Time',
                        timeFormat.format(_ride.departureTime)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.event_seat, 'Available Seats',
                        '${_ride.availableSeats}'),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.payments, 'Price per Seat',
                        _ride.pricePerSeat != null
                            ? '${_ride.pricePerSeat!.toStringAsFixed(2)} PLN'
                            : 'Ask driver'),
                    const Divider(height: 24),
                    _buildInfoRow(
                        Icons.info_outline, 'Status', _ride.rideStatus.name),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Driver Info Card
            if (_ride.driver != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Driver', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          Icons.person,
                          'Name',
                          _ride.driver!.name ??
                              _ride.driver!.username ??
                              'N/A'),
                      if (_ride.driver!.phoneNumber != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                            Icons.phone, 'Phone', _ride.driver!.phoneNumber!),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Book/Cancel Button
            if (_isAlreadyBooked)
              ElevatedButton(
                onPressed: _isBooking ? null : _cancelBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Cancel Booking'),
              )
            else
              ElevatedButton(
                onPressed: _canBook && !_isBooking ? _bookRide : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.white,
                ),
                child: _isBooking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_canBook
                        ? 'Book This Ride'
                        : _ride.rideStatus == RideStatus.FULL
                            ? 'Ride is Full'
                            : 'Not Available'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
