import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/locations/domain/location.dart';
import '../../../../core/locations/widgets/location_autocomplete_field.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../routes/routes.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../presentation/providers/paginated_rides_provider.dart';
import 'post_ride_controller.dart';
import 'widgets/part_of_day_selector.dart';
import 'widgets/smart_match_sheet.dart';
import 'widgets/time_mode_selector.dart';

class PostRideScreen extends ConsumerStatefulWidget {
  final Location? prefillOrigin;

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

  // Track last selected locations to detect user typing over selection
  Location? _lastSelectedOrigin;
  Location? _lastSelectedDestination;

  // Intermediate stop controllers
  final List<TextEditingController> _stopCityControllers = [];
  final List<TextEditingController> _stopTimeControllers = [];
  final List<Location?> _lastSelectedStopLocations = [];

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController();
    _destinationController = TextEditingController();

    // Clear selection if user types after selecting (text no longer matches)
    _originController.addListener(_onOriginTextChanged);
    _destinationController.addListener(_onDestinationTextChanged);

    // Prefill origin from navigation extra
    if (widget.prefillOrigin != null) {
      final location = widget.prefillOrigin!;
      _originController.text = location.name;
      _lastSelectedOrigin = location;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(postRideControllerProvider.notifier).setOrigin(location);
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

  void _ensureStopControllers(int count) {
    while (_stopCityControllers.length < count) {
      _stopCityControllers.add(TextEditingController());
      _stopTimeControllers.add(TextEditingController());
      _lastSelectedStopLocations.add(null);
    }
    while (_stopCityControllers.length > count) {
      _stopCityControllers.removeLast().dispose();
      _stopTimeControllers.removeLast().dispose();
      _lastSelectedStopLocations.removeLast();
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
    for (final c in _stopCityControllers) {
      c.dispose();
    }
    for (final c in _stopTimeControllers) {
      c.dispose();
    }
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

  Future<void> _pickStopTime(BuildContext context, int index) async {
    final controller = ref.read(postRideControllerProvider.notifier);
    final state = ref.read(postRideControllerProvider);
    final stop = state.intermediateStops[index];

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: stop.departureTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      controller.setIntermediateStopTime(index, pickedTime);
      final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
      _stopTimeControllers[index].text = '$hour:$minute $period';
    }
  }

  void _onSubmit() {
    final controller = ref.read(postRideControllerProvider.notifier);

    // Sync text field values to controller before validation
    final seats = int.tryParse(_seatsController.text);
    controller.setAvailableSeats(seats);
    if (!ref.read(postRideControllerProvider).isNegotiablePrice) {
      final price = int.tryParse(_priceController.text);
      controller.setPricePerSeat(price);
    }
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

    // Keep controllers in sync with state
    _ensureStopControllers(state.intermediateStops.length);

    // Listen for navigation and error events
    ref.listen(postRideControllerProvider, (prev, next) {
      // One-shot: only navigate if createdRideId is set AND not yet navigated
      if (next.createdRideId != null && !next.hasNavigated) {
        // Mark as navigated FIRST to prevent double navigation on rebuild
        ref.read(postRideControllerProvider.notifier).markNavigated();

        // Invalidate caches
        final offerKey = OfferKey(OfferKind.ride, next.createdRideId!);
        ref.invalidate(offerDetailProvider(offerKey));
        ref.read(paginatedRidesProvider.notifier).refresh();

        // Show Smart Match sheet — navigates to offer details on close
        if (next.origin != null &&
            next.destination != null &&
            next.selectedDate != null) {
          showSmartMatchSheet(
            context,
            origin: next.origin!,
            destination: next.destination!,
            departureDate: next.selectedDate!,
            createdRideId: next.createdRideId!,
          );
        } else {
          // Fallback: direct navigation if form data is somehow incomplete
          context.goNamed(
            RouteNames.offerDetails,
            pathParameters: {'offerKey': offerKey.toRouteParam()},
          );
        }
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
      appBar: AppBar(title: Text(context.l10n.postYourRide)),
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
                      context.l10n.offerARideHeader,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Origin Location
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: LocationAutocompleteField(
                      controller: _originController,
                      labelText: context.l10n.originCityLabel,
                      prefixIcon: Icons.trip_origin,
                      onLocationSelected: (location) {
                        _originController.text = location.name;
                        _lastSelectedOrigin = location;
                        controller.setOrigin(location);
                      },
                      onLocationCleared: () {
                        _lastSelectedOrigin = null;
                        controller.clearOrigin();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.originRequired;
                        }
                        if (state.origin == null) {
                          return context.l10n.selectOriginFromSuggestions;
                        }
                        return null;
                      },
                    ),
                  ),

                  // Destination Location
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: LocationAutocompleteField(
                      controller: _destinationController,
                      labelText: context.l10n.destinationCityLabel,
                      prefixIcon: Icons.flag_outlined,
                      onLocationSelected: (location) {
                        _destinationController.text = location.name;
                        _lastSelectedDestination = location;
                        controller.setDestination(location);
                      },
                      onLocationCleared: () {
                        _lastSelectedDestination = null;
                        controller.clearDestination();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.destinationRequired;
                        }
                        if (state.destination == null) {
                          return context.l10n.selectDestinationFromSuggestions;
                        }
                        if (state.origin != null &&
                            state.destination != null &&
                            state.origin!.osmId ==
                                state.destination!.osmId) {
                          return context.l10n.mustDifferFromOrigin;
                        }
                        return null;
                      },
                    ),
                  ),

                  // Intermediate Stops Section
                  ..._buildIntermediateStopsSection(state, controller, colorScheme, textTheme),

                  // Date
                  AppTextField(
                    controller: _dateController,
                    label: context.l10n.dateOfDeparture,
                    prefixIcon: Icons.calendar_today_outlined,
                    suffixIcon: Icons.arrow_drop_down,
                    onTap: () => _pickDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return context.l10n.selectDepartureDate;
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
                            context.l10n.timeOfDay,
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
                      label: context.l10n.timeOfDeparture,
                      prefixIcon: Icons.access_time_outlined,
                      suffixIcon: Icons.arrow_drop_down,
                      onTap: () => _pickTime(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.l10n.selectDepartureTime;
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
                      decoration: InputDecoration(
                        labelText: context.l10n.availableSeatsLabel,
                        prefixIcon: const Icon(Icons.airline_seat_recline_normal),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return context.l10n.required;
                        final n = int.tryParse(value!);
                        if (n == null || n < 1 || n > 8) {
                          return context.l10n.seatsRange;
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
                      enabled: !state.isNegotiablePrice,
                      decoration: InputDecoration(
                        labelText: context.l10n.pricePerSeatLabel,
                        suffixText: 'PLN',
                      ),
                      validator: (value) {
                        if (state.isNegotiablePrice) return null;
                        if (value?.isEmpty ?? true) return context.l10n.required;
                        final n = int.tryParse(value!);
                        if (n == null || n < 1 || n > 999) {
                          return context.l10n.priceRange;
                        }
                        return null;
                      },
                    ),
                  ),

                  // Negotiable price toggle
                  CheckboxListTile(
                    title: Text(context.l10n.negotiablePrice),
                    value: state.isNegotiablePrice,
                    onChanged: (v) => controller.setNegotiablePrice(v ?? false),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  // Description
                  AppTextField(
                    controller: _descriptionController,
                    label: context.l10n.rideDescriptionOptional,
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 4,
                    minLines: 2,
                    validator: (value) {
                      if (value != null && value.length > 500) {
                        return context.l10n.maxCharacters(500);
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28.0),

                  // Submit Button
                  PrimaryButton(
                    onPressed: state.isSubmitting ? null : _onSubmit,
                    isLoading: state.isSubmitting,
                    child: Text(context.l10n.postRide),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIntermediateStopsSection(
    PostRideFormState state,
    PostRideController controller,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return [
      for (int i = 0; i < state.intermediateStops.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LocationAutocompleteField(
                          controller: _stopCityControllers[i],
                          labelText: context.l10n.intermediateStopLabel(i + 1),
                          prefixIcon: Icons.add_location_alt_outlined,
                          onLocationSelected: (location) {
                            _stopCityControllers[i].text = location.name;
                            _lastSelectedStopLocations[i] = location;
                            controller.setIntermediateStopLocation(i, location);
                          },
                          onLocationCleared: () {
                            _lastSelectedStopLocations[i] = null;
                            controller.clearIntermediateStopLocation(i);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          controller.removeIntermediateStop(i);
                        },
                        color: colorScheme.error,
                        tooltip: context.l10n.removeStop,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _stopTimeControllers[i],
                    label: context.l10n.stopDepartureTime,
                    prefixIcon: Icons.access_time_outlined,
                    suffixIcon: Icons.arrow_drop_down,
                    onTap: () => _pickStopTime(context, i),
                  ),
                ],
              ),
            ),
          ),
        ),

      // Add stop button
      if (state.intermediateStops.length < 3)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextButton.icon(
            onPressed: controller.addIntermediateStop,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(context.l10n.addStop),
          ),
        ),
    ];
  }
}
