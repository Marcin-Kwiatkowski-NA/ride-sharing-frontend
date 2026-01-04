import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'CityAutocompleteField.dart';

class PostRideScreen extends StatefulWidget {
  const PostRideScreen({super.key});

  @override
  State<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends State<PostRideScreen> {
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
        'name': _originController.text, // Add this line
      },
      'destination': {
        'osmId': _destinationCityOsmId,
        'name': _destinationController.text, // Add this line
      },
      'departureTime': formattedDepartureTime,
      'availableSeats': int.parse(_seatsController.text.trim()),
      'pricePerSeat': pricePerSeatVal,
      'vehicleId': _vehicleId,
      'description': descriptionVal.isNotEmpty ? descriptionVal : null, // Send description
    };

    //
    // --- 3. MAKE THE API CALL ---
    //
    const String apiUrl = 'http://vamos.130.61.31.172.sslip.io/rides';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(rideData),
      );

      if (response.statusCode == 201) { // Typically 201 Created for POST
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ride posted successfully!'), backgroundColor: Colors.green),
        );
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
      } else {
        // Your existing excellent error handling
        String errorMessage = 'Failed to post ride. Status: ${response.statusCode}';
        // ... (error parsing logic from your original code) ...
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      setState(() { _isLoading = false; });
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

  // This helper function is now only used for non-autocomplete fields
  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String labelText,
    required BuildContext context,
    IconData? prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isMultiline = false,
    int minLines = 1,
    int maxLines = 1,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
    String? hintText,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        minLines: isMultiline ? minLines : null,
        maxLines: isMultiline ? maxLines : null,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
          hintText: hintText ?? "Enter $labelText",
          hintStyle: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: theme.colorScheme.primary, size: 22) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7), size: 22) : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.85),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        ),
        style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Post Your Ride 🚐')),
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

                  _buildStyledTextField(
                    controller: _dateController,
                    labelText: 'Date of Departure',
                    prefixIcon: Icons.calendar_today_outlined,
                    suffixIcon: Icons.arrow_drop_down,
                    readOnly: true,
                    context: context,
                    onTap: () => _pickDate(context),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please select a date.' : null,
                  ),
                  _buildStyledTextField(
                    controller: _timeController,
                    labelText: 'Time of Departure',
                    prefixIcon: Icons.access_time_outlined,
                    suffixIcon: Icons.arrow_drop_down,
                    readOnly: true,
                    context: context,
                    onTap: () => _pickTime(context),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please select a time.' : null,
                  ),
                  _buildStyledTextField(
                    controller: _seatsController,
                    labelText: 'Available Seats',
                    prefixIcon: Icons.event_seat_outlined,
                    keyboardType: TextInputType.number,
                    context: context,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Number of seats is required.';
                      final n = int.tryParse(value);
                      if (n == null) return 'Please enter a valid number.';
                      if (n < 1) return 'Seats must be at least 1.';
                      return null;
                    },
                  ),
                  _buildStyledTextField(
                    controller: _priceController,
                    labelText: 'Price per Seat (PLN)',
                    prefixIcon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    context: context,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Price is required.';
                      final price = double.tryParse(value.replaceAll(',', '.'));
                      if (price == null) return 'Please enter a valid price.';
                      if (price < 0) return 'Price cannot be negative.';
                      return null;
                    },
                  ),
                  _buildStyledTextField(
                    controller: _descriptionController,
                    labelText: 'Ride Description (Optional)',
                    prefixIcon: Icons.notes_outlined,
                    isMultiline: true,
                    minLines: 2,
                    maxLines: 4,
                    context: context,
                  ),
                  const SizedBox(height: 28.0),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitRide,
                    style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      textStyle: MaterialStateProperty.resolveWith((states) {
                        final originalStyle = Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve(states);
                        return originalStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 18);
                      }),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text('Post Ride'),
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
