import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/cities/domain/city.dart';
import '../../../../core/cities/widgets/city_autocomplete_field.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../routes/routes.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../presentation/providers/paginated_rides_provider.dart';
import 'post_ride_controller.dart';
import 'widgets/part_of_day_selector.dart';
import 'widgets/time_mode_selector.dart';

class PostRideScreen extends ConsumerStatefulWidget {
  final City? prefillOrigin;

  const PostRideScreen({super.key, this.prefillOrigin});

  @override
  ConsumerState<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends ConsumerState<PostRideScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _originController;
  late final TextEditingController _destinationController;
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _seatsController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Track last selected cities to detect user typing over selection
  City? _lastSelectedOrigin;
  City? _lastSelectedDestination;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController();
    _destinationController = TextEditingController();

    // Clear placeId if user types after selecting (text no longer matches)
    _originController.addListener(_onOriginTextChanged);
    _destinationController.addListener(_onDestinationTextChanged);

    // Prefill origin from navigation extra
    if (widget.prefillOrigin != null) {
      final city = widget.prefillOrigin!;
      _originController.text = city.name;
      _lastSelectedOrigin = city;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(postRideControllerProvider.notifier).setOrigin(city);
      });
    }
  }

  void _onOriginTextChanged() {
    if (_lastSelectedOrigin != null &&
        _originController.text != _lastSelectedOrigin!.name) {
      _lastSelectedOrigin = null;
      ref.read(postRideControllerProvider.notifier).clearOrigin();
    }
  }

  void _onDestinationTextChanged() {
    if (_lastSelectedDestination != null &&
        _destinationController.text != _lastSelectedDestination!.name) {
      _lastSelectedDestination = null;
      ref.read(postRideControllerProvider.notifier).clearDestination();
    }
  }

  @override
  void dispose() {
    _originController.removeListener(_onOriginTextChanged);
    _destinationController.removeListener(_onDestinationTextChanged);
    _originController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final controller = ref.read(postRideControllerProvider.notifier);
    final state = ref.read(postRideControllerProvider);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: state.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null) {
      controller.setSelectedDate(pickedDate);
      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final controller = ref.read(postRideControllerProvider.notifier);
    final state = ref.read(postRideControllerProvider);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: state.exactTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      controller.setExactTime(pickedTime);
      // Format time without using context across async gap
      final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
      _timeController.text = '$hour:$minute $period';
    }
  }

  void _onSubmit() {
    final controller = ref.read(postRideControllerProvider.notifier);

    // Sync text field values to controller before validation
    final seats = int.tryParse(_seatsController.text);
    final price = int.tryParse(_priceController.text);
    controller.setAvailableSeats(seats);
    controller.setPricePerSeat(price);
    controller.setDescription(_descriptionController.text);

    // Submit
    controller.submit();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(postRideControllerProvider);
    final controller = ref.read(postRideControllerProvider.notifier);

    // Listen for navigation and error events
    ref.listen(postRideControllerProvider, (prev, next) {
      // One-shot: only navigate if createdRideId is set AND not yet navigated
      if (next.createdRideId != null && !next.hasNavigated) {
        // Mark as navigated FIRST to prevent double navigation on rebuild
        ref.read(postRideControllerProvider.notifier).markNavigated();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ride created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Invalidate caches
        final offerKey = OfferKey(OfferKind.ride, next.createdRideId!);
        ref.invalidate(offerDetailProvider(offerKey));
        ref.read(paginatedRidesProvider.notifier).refresh();

        // Navigate (replace so user can't go back to form)
        context.goNamed(
          RouteNames.offerDetails,
          pathParameters: {'offerKey': offerKey.toRouteParam()},
        );
      }

      // Show error snackbar
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Post Your Ride')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                    child: Text(
                      'Offer a Ride',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Origin City
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: CityAutocompleteField(
                      controller: _originController,
                      labelText: 'Origin City',
                      prefixIcon: Icons.trip_origin,
                      onCitySelected: (city) {
                        _originController.text = city.name;
                        _lastSelectedOrigin = city;
                        controller.setOrigin(city);
                      },
                      onCityCleared: () {
                        _lastSelectedOrigin = null;
                        controller.clearOrigin();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Origin City is required';
                        }
                        if (state.origin == null) {
                          return 'Select origin from suggestions';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Destination City
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: CityAutocompleteField(
                      controller: _destinationController,
                      labelText: 'Destination City',
                      prefixIcon: Icons.flag_outlined,
                      onCitySelected: (city) {
                        _destinationController.text = city.name;
                        _lastSelectedDestination = city;
                        controller.setDestination(city);
                      },
                      onCityCleared: () {
                        _lastSelectedDestination = null;
                        controller.clearDestination();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Destination City is required';
                        }
                        if (state.destination == null) {
                          return 'Select destination from suggestions';
                        }
                        if (state.origin != null &&
                            state.destination != null &&
                            state.origin!.placeId ==
                                state.destination!.placeId) {
                          return 'Must differ from origin';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Date
                  AppTextField(
                    controller: _dateController,
                    label: 'Date of Departure',
                    prefixIcon: Icons.calendar_today_outlined,
                    suffixIcon: Icons.arrow_drop_down,
                    onTap: () => _pickDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Select departure date';
                      }
                      return null;
                    },
                  ),

                  // Time Mode Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TimeModeSelector(
                      isApproximate: state.isApproximate,
                      onChanged: controller.setIsApproximate,
                    ),
                  ),

                  // Time selection based on mode
                  if (state.isApproximate) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time of Day',
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          PartOfDaySelector(
                            selected: state.partOfDay,
                            onSelected: controller.setPartOfDay,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    AppTextField(
                      controller: _timeController,
                      label: 'Time of Departure',
                      prefixIcon: Icons.access_time_outlined,
                      suffixIcon: Icons.arrow_drop_down,
                      onTap: () => _pickTime(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Select departure time';
                        }
                        return null;
                      },
                    ),
                  ],

                  // Available Seats (plain TextFormField)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: _seatsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Available Seats',
                        prefixIcon: Icon(Icons.airline_seat_recline_normal),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final n = int.tryParse(value!);
                        if (n == null || n < 1 || n > 8) {
                          return '1-8 seats allowed';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Price per Seat (plain TextFormField)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Price per Seat',
                        suffixText: 'PLN',
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Required';
                        final n = int.tryParse(value!);
                        if (n == null || n < 1 || n > 999) {
                          return '1-999 PLN';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Description
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Ride Description (Optional)',
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 4,
                    minLines: 2,
                    validator: (value) {
                      if (value != null && value.length > 500) {
                        return 'Max 500 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28.0),

                  // Submit Button
                  PrimaryButton(
                    onPressed: state.isSubmitting ? null : _onSubmit,
                    isLoading: state.isSubmitting,
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
