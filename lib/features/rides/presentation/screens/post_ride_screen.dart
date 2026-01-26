import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:blablafront/core/network/dio_provider.dart';
import 'package:blablafront/core/widgets/core_widgets.dart';
import '../../../../shared/widgets/city_autocomplete_field.dart';

class PostRideScreen extends ConsumerStatefulWidget {
  const PostRideScreen({super.key});

  @override
  ConsumerState<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends ConsumerState<PostRideScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();

  // --- STATE TO HOLD SELECTED CITY IDs ---
  int? _originCityOsmId;
  int? _destinationCityOsmId;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final int _driverId = 1;
  final int _vehicleId = 1;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  // --- SUBMIT RIDE LOGIC ---
  Future<void> _submitRide() async {
    //
    // --- 1. VALIDATE THE FORM & IDs ---
    //
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please correct the errors in the form.'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    // New validation: ensure user selected a city from the list, not just typed a name
    if (_originCityOsmId == null || _destinationCityOsmId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Please select origin and destination from the suggestions.'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    setState(() { _isLoading = true; });

    //
    // --- 2. PREPARE THE DATA PAYLOAD ---
    //
    final departureDateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );
    String formattedDepartureTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(departureDateTime);
    String pricePerSeatVal = _priceController.text.trim().replaceAll(',', '.');
    String descriptionVal = _descriptionController.text.trim();

    final rideData = {
      'driverId': _driverId,
      'origin': {
        'osmId': _originCityOsmId,
        'name': _originController.text,
      },
      'destination': {
        'osmId': _destinationCityOsmId,
        'name': _destinationController.text,
      },
      'departureTime': formattedDepartureTime,
      'availableSeats': int.parse(_seatsController.text.trim()),
      'pricePerSeat': pricePerSeatVal,
      'vehicleId': _vehicleId,
      'description': descriptionVal.isNotEmpty ? descriptionVal : null,
    };

    //
    // --- 3. MAKE THE API CALL ---
    //
    final dio = ref.read(dioProvider);

    try {
      final response = await dio.post('/rides', data: rideData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ride posted successfully!'), backgroundColor: Colors.green),
          );
        }
        // Clear form after success
        _formKey.currentState?.reset();
        _dateController.clear();
        _timeController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
          _originCityOsmId = null;
          _destinationCityOsmId = null;
        });
      }
    } on DioException catch (e) {
      if (!mounted) return;

      if (e.response?.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Session expired. Please log in again.'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      } else if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: ${e.message}'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      } else {
        final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post ride: $errorMessage'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }


  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).dialogBackgroundColor,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Post Your Ride')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16.0)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                    child: Text('Offer a Ride', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.primary), textAlign: TextAlign.center),
                  ),

                  // --- WIDGETS FOR ORIGIN AND DESTINATION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: CityAutocompleteField(
                      controller: _originController,
                      labelText: 'Origin City',
                      prefixIcon: Icons.trip_origin,
                      onCitySelected: (city) { // 'city' is the City object from your autocomplete
                        setState(() {
                          _originController.text = city.name;
                          _originCityOsmId = city.osmId; // STORE THE OSM_ID
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Origin City is required.';
                        if (_originCityOsmId == null) return 'Please select a city from the list.';
                        return null;
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: CityAutocompleteField(
                      controller: _destinationController,
                      labelText: 'Destination City',
                      prefixIcon: Icons.flag_outlined,
                      onCitySelected: (city) { // 'city' is the City object from your autocomplete
                        setState(() {
                          _destinationController.text = city.name;
                          _destinationCityOsmId = city.osmId; // STORE THE OSM_ID
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Destination City is required.';
                        if (_destinationCityOsmId == null) return 'Please select a city from the list.';
                        return null;
                      },
                    ),
                  ),

                  AppTextField(
                    controller: _dateController,
                    label: 'Date of Departure',
                    prefixIcon: Icons.calendar_today_outlined,
                    suffixIcon: Icons.arrow_drop_down,
                    onTap: () => _pickDate(context),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please select a date.' : null,
                  ),
                  AppTextField(
                    controller: _timeController,
                    label: 'Time of Departure',
                    prefixIcon: Icons.access_time_outlined,
                    suffixIcon: Icons.arrow_drop_down,
                    onTap: () => _pickTime(context),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please select a time.' : null,
                  ),
                  AppTextField(
                    controller: _seatsController,
                    label: 'Available Seats',
                    prefixIcon: Icons.event_seat_outlined,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Number of seats is required.';
                      final n = int.tryParse(value);
                      if (n == null) return 'Please enter a valid number.';
                      if (n < 1) return 'Seats must be at least 1.';
                      return null;
                    },
                  ),
                  AppTextField(
                    controller: _priceController,
                    label: 'Price per Seat (PLN)',
                    prefixIcon: Icons.payments_outlined,
                    isCurrency: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Price is required.';
                      final price = double.tryParse(value.replaceAll(',', '.'));
                      if (price == null) return 'Please enter a valid price.';
                      if (price < 0) return 'Price cannot be negative.';
                      return null;
                    },
                  ),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Ride Description (Optional)',
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 4,
                    minLines: 2,
                  ),
                  const SizedBox(height: 28.0),
                  PrimaryButton(
                    onPressed: _isLoading ? null : _submitRide,
                    isLoading: _isLoading,
                    child: const Text('Post Ride'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
