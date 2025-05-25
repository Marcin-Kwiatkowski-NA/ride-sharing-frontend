import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final Long _driverId = 1;
  final Long _vehicleId = 1;

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

  Future<void> _submitRide() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please correct the errors in the form.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    String originCityName = _originController.text.trim();
    String destinationCityName = _destinationController.text.trim();

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid date and time.'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      setState(() { _isLoading = false; });
      return;
    }
    final departureDateTime = DateTime(
      _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
      _selectedTime!.hour, _selectedTime!.minute,
    );
    if (departureDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Departure time must be in the future.'), backgroundColor: Theme.of(context).colorScheme.error),
      );
      setState(() { _isLoading = false; });
      return;
    }
    String formattedDepartureTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(departureDateTime);

    int availableSeatsVal = int.parse(_seatsController.text.trim());

    String pricePerSeatVal = _priceController.text.trim().replaceAll(',', '.');
    try {
      double price = double.parse(pricePerSeatVal);
      if (price < 0) {
        throw const FormatException("Price cannot be negative.");
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid price format or value. Price cannot be negative.'), backgroundColor: Theme.of(context).colorScheme.error));
      setState(() { _isLoading = false; });
      return;
    }

    final rideData = {
      'driverId': _driverId,
      'origin': originCityName,
      'destination': destinationCityName,
      'departureTime': formattedDepartureTime,
      'availableSeats': availableSeatsVal,
      'pricePerSeat': pricePerSeatVal,
      'vehicleId': _vehicleId,
    };

    const String apiUrl = 'http://ow0wk84w4sogcgs8g0s488wg.130.61.31.172.sslip.io/rides';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(rideData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ride posted successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _formKey.currentState?.reset();
        _dateController.clear();
        _timeController.clear();
        setState(() {
          _selectedDate = null;
          _selectedTime = null;
        });

      } else {
        String errorMessage = 'Failed to post ride. Status: ${response.statusCode}';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            if (errorData is Map) {
              if(errorData.containsKey('message')) errorMessage = errorData['message'];
              if (errorData.containsKey('errors') && errorData['errors'] is Map) {
                (errorData['errors'] as Map).forEach((key, value) {
                  errorMessage += '\n- $key: $value';
                });
              } else if (errorData.containsKey('error')) {
                errorMessage += '\nDetails: ${errorData['error']}';
              }
            } else {
              errorMessage += '\nResponse: ${response.body}';
            }
          } catch (e) {
            errorMessage += '\nError parsing response: ${response.body}';
          }
        }
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage, maxLines: 5, overflow: TextOverflow.ellipsis,), backgroundColor: Theme.of(context).colorScheme.error, duration: const Duration(seconds: 7), behavior: SnackBarBehavior.floating,),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'), backgroundColor: Theme.of(context).colorScheme.error, behavior: SnackBarBehavior.floating,),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
      appBar: AppBar(
        title: const Text('Post Your Ride 🚐'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.titleTextStyle?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                    child: Text(
                      'Offer a Ride',
                      style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: colorScheme.primary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  _buildStyledTextField(
                    controller: _originController,
                    labelText: 'Origin City Name',
                    hintText: 'e.g., New York',
                    prefixIcon: Icons.trip_origin,
                    context: context,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Origin City Name is required.';
                      if (value.length > 100) return 'Origin city name cannot exceed 100 characters.';
                      return null;
                    },
                  ),
                  _buildStyledTextField(
                    controller: _destinationController,
                    labelText: 'Destination City Name',
                    hintText: 'e.g., Boston',
                    prefixIcon: Icons.flag_outlined,
                    context: context,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Destination City Name is required.';
                      if (value.length > 100) return 'Destination city name cannot exceed 100 characters.';
                      return null;
                    },
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

typedef Long = int;