import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/locations/domain/location.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../routes/routes.dart';
import '../../../../shared/widgets/departure_time_section.dart';
import '../../../../shared/widgets/location_picker_dialog.dart';
import '../../../../shared/widgets/number_stepper.dart';
import '../../../../shared/widgets/route_timeline_section.dart';
import '../../../../shared/widgets/time_picker_sheet.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/my_offers_provider.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../presentation/providers/paginated_rides_provider.dart';
import 'post_ride_controller.dart';

class PostRideScreen extends ConsumerStatefulWidget {
  final Location? prefillOrigin;

  const PostRideScreen({super.key, this.prefillOrigin});

  @override
  ConsumerState<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends ConsumerState<PostRideScreen> {
  final _formKey = GlobalKey<FormState>();
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
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation(
    String title,
    void Function(Location) onSelected,
  ) async {
    final location = await showLocationPickerDialog(context, title: title);
    if (location != null) onSelected(location);
  }

  Future<void> _pickStopLocation(int index) async {
    final location = await showLocationPickerDialog(
      context,
      title: 'Stop ${index + 1}',
    );
    if (location != null) {
      ref
          .read(postRideControllerProvider.notifier)
          .setIntermediateStopLocation(index, location);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final state = ref.read(postRideControllerProvider);

    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      ref.read(postRideControllerProvider.notifier).setSelectedDate(picked);
    }
  }

  Future<void> _pickTime() async {
    final controller = ref.read(postRideControllerProvider.notifier);
    final state = ref.read(postRideControllerProvider);

    await showTimePickerSheet(
      context,
      currentTime: state.isApproximate ? null : state.exactTime,
      currentPartOfDay: state.isApproximate ? state.partOfDay : null,
      onExactTimePicked: (time) {
        controller.setIsApproximate(false);
        controller.setExactTime(time);
      },
      onPartOfDayPicked: (pod) {
        controller.setIsApproximate(true);
        controller.setPartOfDay(pod);
      },
    );
  }

  Future<void> _pickStopTime(int index) async {
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
        ref.invalidate(myOffersProvider);
        ref.read(paginatedRidesProvider.notifier).refresh();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.inversePrimary),
                const SizedBox(width: 8),
                Text(context.l10n.smartMatchRideLive),
              ],
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.goNamed(
          RouteNames.myOfferDetails,
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
      appBar: AppBar(title: Text(context.l10n.postYourRide)),
      body: PageLayout.form(
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
                        title: context.l10n.sectionRoute,
                        isFirst: true,
                      ),
                      RouteTimelineSection(
                        originLabel: context.l10n.fromLabel,
                        destinationLabel: context.l10n.toLabel,
                        addStopLabel: context.l10n.addStop,
                        origin: state.origin,
                        destination: state.destination,
                        onOriginTap: () => _pickLocation(
                          context.l10n.fromLabel,
                          controller.setOrigin,
                        ),
                        onDestinationTap: () => _pickLocation(
                          context.l10n.toLabel,
                          controller.setDestination,
                        ),
                        originError:
                            showErrors ? state.originError : null,
                        destinationError:
                            showErrors ? state.destinationError : null,
                        stops: state.intermediateStops
                            .map((s) => RouteStopData(
                                  id: s.id,
                                  locationName: s.location?.name,
                                  departureTime: s.departureTime,
                                ))
                            .toList(),
                        onStopTap: (i) => _pickStopLocation(i),
                        onStopTimeTap: (i) => _pickStopTime(i),
                        onStopRemove: controller.removeIntermediateStop,
                        onStopReorder: controller.reorderStops,
                        onAddStop: controller.addIntermediateStop,
                        maxStops: 3,
                        stopsError:
                            showErrors ? state.stopsError : null,
                      ),
                    ],
                  ),
                ),
              ),

              // ── When Section ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.calendar_month,
                        title: context.l10n.sectionWhen,
                      ),
                      DepartureTimeSection(
                        selectedDate: state.selectedDate,
                        exactTime: state.exactTime,
                        selectedPartOfDay: state.partOfDay,
                        isApproximate: state.isApproximate,
                        onDateTap: _pickDate,
                        onTimeTap: _pickTime,
                        dateError: showErrors ? state.dateError : null,
                        timeError: showErrors ? state.timeError : null,
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
                      _SectionHeader(
                        icon: Icons.tune,
                        title: context.l10n.sectionDetails,
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
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: PageBottomArea(
        child: PrimaryButton(
          onPressed: state.isSubmitting ? null : _onSubmit,
          isLoading: state.isSubmitting,
          child: Text(context.l10n.postRide),
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
