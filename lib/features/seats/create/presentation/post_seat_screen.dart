import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/cities/domain/city.dart';
import '../../../../core/cities/widgets/city_autocomplete_field.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../routes/routes.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../presentation/providers/paginated_seats_provider.dart';
import '../../../rides/create/presentation/widgets/part_of_day_selector.dart';
import '../../../rides/create/presentation/widgets/time_mode_selector.dart';
import 'post_seat_controller.dart';

class PostSeatScreen extends ConsumerStatefulWidget {
  final City? prefillOrigin;
  final City? prefillDestination;
  final DateTime? prefillDate;

  const PostSeatScreen({
    super.key,
    this.prefillOrigin,
    this.prefillDestination,
    this.prefillDate,
  });

  @override
  ConsumerState<PostSeatScreen> createState() => _PostSeatScreenState();
}

class _PostSeatScreenState extends ConsumerState<PostSeatScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _originController;
  late final TextEditingController _destinationController;
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _countController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  City? _lastSelectedOrigin;
  City? _lastSelectedDestination;

  @override
  void initState() {
    super.initState();
    _originController = TextEditingController();
    _destinationController = TextEditingController();

    _originController.addListener(_onOriginTextChanged);
    _destinationController.addListener(_onDestinationTextChanged);

    if (widget.prefillOrigin != null) {
      final city = widget.prefillOrigin!;
      _originController.text = city.name;
      _lastSelectedOrigin = city;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(postSeatControllerProvider.notifier).setOrigin(city);
      });
    }

    if (widget.prefillDestination != null) {
      final city = widget.prefillDestination!;
      _destinationController.text = city.name;
      _lastSelectedDestination = city;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(postSeatControllerProvider.notifier).setDestination(city);
      });
    }

    if (widget.prefillDate != null) {
      final date = widget.prefillDate!;
      _dateController.text = DateFormat('yyyy-MM-dd').format(date);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(postSeatControllerProvider.notifier).setSelectedDate(date);
      });
    }
  }

  void _onOriginTextChanged() {
    if (_lastSelectedOrigin != null &&
        _originController.text != _lastSelectedOrigin!.name) {
      _lastSelectedOrigin = null;
      ref.read(postSeatControllerProvider.notifier).clearOrigin();
    }
  }

  void _onDestinationTextChanged() {
    if (_lastSelectedDestination != null &&
        _destinationController.text != _lastSelectedDestination!.name) {
      _lastSelectedDestination = null;
      ref.read(postSeatControllerProvider.notifier).clearDestination();
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
    _countController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final controller = ref.read(postSeatControllerProvider.notifier);
    final state = ref.read(postSeatControllerProvider);

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
    final controller = ref.read(postSeatControllerProvider.notifier);
    final state = ref.read(postSeatControllerProvider);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: state.exactTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      controller.setExactTime(pickedTime);
      final hour =
          pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final period = pickedTime.period == DayPeriod.am ? 'AM' : 'PM';
      _timeController.text = '$hour:$minute $period';
    }
  }

  void _onSubmit() {
    final controller = ref.read(postSeatControllerProvider.notifier);

    final count = int.tryParse(_countController.text);
    final budget = int.tryParse(_budgetController.text);
    controller.setCount(count);
    controller.setPriceWillingToPay(budget);
    controller.setDescription(_descriptionController.text);

    controller.submit();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(postSeatControllerProvider);
    final controller = ref.read(postSeatControllerProvider.notifier);

    ref.listen(postSeatControllerProvider, (prev, next) {
      if (next.createdSeatId != null && !next.hasNavigated) {
        ref.read(postSeatControllerProvider.notifier).markNavigated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.seatRequestCreated),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        final offerKey = OfferKey(OfferKind.seat, next.createdSeatId!);
        ref.invalidate(offerDetailProvider(offerKey));
        ref.read(paginatedSeatsProvider.notifier).refresh();

        context.goNamed(
          RouteNames.offerDetails,
          pathParameters: {'offerKey': offerKey.toRouteParam()},
        );
      }

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
      appBar: AppBar(title: Text(context.l10n.postSeatRequest)),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                    child: Text(
                      context.l10n.findARideHeader,
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
                      labelText: context.l10n.originCityLabel,
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
                          return context.l10n.originRequired;
                        }
                        if (state.origin == null) {
                          return context.l10n.selectOriginFromSuggestions;
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
                      labelText: context.l10n.destinationCityLabel,
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
                          return context.l10n.destinationRequired;
                        }
                        if (state.destination == null) {
                          return context.l10n.selectDestinationFromSuggestions;
                        }
                        if (state.origin != null &&
                            state.destination != null &&
                            state.origin!.placeId ==
                                state.destination!.placeId) {
                          return context.l10n.mustDifferFromOrigin;
                        }
                        return null;
                      },
                    ),
                  ),

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

                  // Passengers needed
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: context.l10n.passengersNeeded,
                        prefixIcon: const Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return context.l10n.required;
                        final n = int.tryParse(value!);
                        if (n == null || n < 1 || n > 8) {
                          return context.l10n.passengersRange;
                        }
                        return null;
                      },
                    ),
                  ),

                  // Budget (optional)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: context.l10n.budgetOptional,
                        suffixText: 'PLN',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final n = int.tryParse(value);
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
                    label: context.l10n.descriptionOptional,
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

                  PrimaryButton(
                    onPressed: state.isSubmitting ? null : _onSubmit,
                    isLoading: state.isSubmitting,
                    child: Text(context.l10n.postSeatRequest),
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
