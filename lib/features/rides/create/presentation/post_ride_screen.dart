import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/locations/domain/location.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../routes/routes.dart';
import '../../../../shared/widgets/departure_picker_helpers.dart';
import '../../../../shared/widgets/departure_time_section.dart';
import '../../../../shared/widgets/location_picker_dialog.dart';
import '../../../../shared/widgets/number_stepper.dart';
import '../../../../shared/widgets/route_timeline.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../presentation/providers/paginated_rides_provider.dart';
import 'post_ride_controller.dart';
import 'widgets/smart_match_sheet.dart';

class PostRideScreen extends ConsumerStatefulWidget {
  final Location? prefillOrigin;

  const PostRideScreen({super.key, this.prefillOrigin});

  @override
  ConsumerState<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends ConsumerState<PostRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefillOrigin != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(postRideControllerProvider.notifier)
            .setOrigin(widget.prefillOrigin!);
      });
    }
  }

  @override
  void dispose() {
    _timeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(BuildContext context) async {
    final controller = ref.read(postRideControllerProvider.notifier);
    final state = ref.read(postRideControllerProvider);

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: state.exactTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      controller.setExactTime(pickedTime);
      _timeController.text = formatPickedTime(pickedTime);
    }
  }

  Future<void> _pickStopTime(BuildContext context, int index) async {
    final controller = ref.read(postRideControllerProvider.notifier);
    final state = ref.read(postRideControllerProvider);
    final stop = state.intermediateStops[index];

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: stop.departureTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      controller.setIntermediateStopTime(index, pickedTime);
    }
  }

  void _onSubmit() {
    // Sync text field values to controller
    final controller = ref.read(postRideControllerProvider.notifier);
    if (!ref.read(postRideControllerProvider).isNegotiablePrice) {
      final price = int.tryParse(_priceController.text);
      controller.setPricePerSeat(price);
    }
    controller.setDescription(_descriptionController.text);
    controller.submit();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(postRideControllerProvider);
    final controller = ref.read(postRideControllerProvider.notifier);
    final showErrors = state.hasAttemptedSubmit;

    // Listen for navigation and error events
    ref.listen(postRideControllerProvider, (prev, next) {
      if (next.createdRideId != null && !next.hasNavigated) {
        ref.read(postRideControllerProvider.notifier).markNavigated();

        final offerKey = OfferKey(OfferKind.ride, next.createdRideId!);
        ref.invalidate(offerDetailProvider(offerKey));
        ref.read(paginatedRidesProvider.notifier).refresh();

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
          context.goNamed(
            RouteNames.offerDetails,
            pathParameters: {'offerKey': offerKey.toRouteParam()},
          );
        }
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
      appBar: AppBar(title: Text(context.l10n.postYourRide)),
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: CustomScrollView(
            slivers: [
              // ── Route Section ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.route,
                        title: 'Route',
                        isFirst: true,
                      ),
                      RouteTimeline(
                        origin: state.origin,
                        destination: state.destination,
                        onOriginTap: () async {
                          final location = await showLocationPickerDialog(
                            context,
                            title: context.l10n.fromLabel,
                          );
                          if (location != null) controller.setOrigin(location);
                        },
                        onDestinationTap: () async {
                          final location = await showLocationPickerDialog(
                            context,
                            title: context.l10n.toLabel,
                          );
                          if (location != null) {
                            controller.setDestination(location);
                          }
                        },
                        originError:
                            showErrors ? state.originError : null,
                        destinationError:
                            showErrors ? state.destinationError : null,
                      ),
                      if (state.intermediateStops.length < 3)
                        TextButton.icon(
                          onPressed: controller.addIntermediateStop,
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: Text(context.l10n.addStop),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Reorderable Intermediate Stops ─────────────────────
              if (state.intermediateStops.isNotEmpty)
                SliverReorderableList(
                  itemCount: state.intermediateStops.length,
                  onReorder: controller.reorderStops,
                  itemBuilder: (context, index) {
                    final stop = state.intermediateStops[index];
                    return Padding(
                      key: ValueKey(stop.id),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Diamond icon
                              Icon(
                                Icons.diamond_outlined,
                                size: 18,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              // Stop location
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final location =
                                        await showLocationPickerDialog(
                                      context,
                                      title: 'Stop ${index + 1}',
                                    );
                                    if (location != null) {
                                      controller
                                          .setIntermediateStopLocation(
                                        index,
                                        location,
                                      );
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stop.location?.name ??
                                            'Choose stop ${index + 1}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      if (stop.departureTime != null)
                                        Text(
                                          formatPickedTime(
                                              stop.departureTime!),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              // Time picker
                              IconButton(
                                icon: const Icon(Icons.access_time, size: 20),
                                onPressed: () =>
                                    _pickStopTime(context, index),
                                tooltip: 'Set time',
                              ),
                              // Drag handle — only this triggers reorder
                              ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle, size: 20),
                              ),
                              // Remove
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () =>
                                    controller.removeIntermediateStop(index),
                                color: colorScheme.error,
                                tooltip: context.l10n.removeStop,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // ── When Section ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        icon: Icons.calendar_month,
                        title: 'When',
                      ),
                      DepartureTimeSection(
                        selectedDate: state.selectedDate,
                        onDateSelected: controller.setSelectedDate,
                        dateError: showErrors ? state.dateError : null,
                        isApproximate: state.isApproximate,
                        onIsApproximateChanged: controller.setIsApproximate,
                        exactTime: state.exactTime,
                        timeController: _timeController,
                        onPickTime: () => _pickTime(context),
                        timeError: showErrors ? state.timeError : null,
                        selectedPartOfDay: state.partOfDay,
                        onPartOfDaySelected: controller.setPartOfDay,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Details Section ────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionHeader(
                        icon: Icons.tune,
                        title: 'Details',
                      ),
                      NumberStepper(
                        value: state.availableSeats,
                        min: 1,
                        max: 8,
                        onChanged: controller.setAvailableSeats,
                        label: context.l10n.availableSeatsLabel,
                        errorText: showErrors ? state.seatsError : null,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _priceController,
                              label: context.l10n.pricePerSeatLabel,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              suffixText: 'PLN',
                              enabled: !state.isNegotiablePrice,
                              errorText: showErrors ? state.priceError : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch.adaptive(
                                  value: state.isNegotiablePrice,
                                  onChanged: (v) =>
                                      controller.setNegotiablePrice(v),
                                ),
                                Text(
                                  context.l10n.negotiablePrice,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AppTextField(
                        controller: _descriptionController,
                        label: context.l10n.rideDescriptionOptional,
                        prefixIcon: Icons.notes_outlined,
                        maxLines: 4,
                        minLines: 2,
                      ),
                      if (showErrors && state.stopsError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 12),
                          child: Text(
                            state.stopsError!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.error,
                                    ),
                          ),
                        ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: PrimaryButton(
              onPressed: state.isSubmitting ? null : _onSubmit,
              isLoading: state.isSubmitting,
              child: Text(context.l10n.postRide),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isFirst;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (!isFirst) const Divider(height: 24),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
