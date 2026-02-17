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
import '../../presentation/providers/paginated_seats_provider.dart';
import 'post_seat_controller.dart';

class PostSeatScreen extends ConsumerStatefulWidget {
  final Location? prefillOrigin;
  final Location? prefillDestination;
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
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(postSeatControllerProvider.notifier);
      if (widget.prefillOrigin != null) {
        controller.setOrigin(widget.prefillOrigin!);
      }
      if (widget.prefillDestination != null) {
        controller.setDestination(widget.prefillDestination!);
      }
      if (widget.prefillDate != null) {
        controller.setSelectedDate(widget.prefillDate!);
      }
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final state = ref.read(postSeatControllerProvider);

    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      ref.read(postSeatControllerProvider.notifier).setSelectedDate(picked);
    }
  }

  Future<void> _pickTime() async {
    final controller = ref.read(postSeatControllerProvider.notifier);
    final state = ref.read(postSeatControllerProvider);

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

  void _onSubmit() {
    final controller = ref.read(postSeatControllerProvider.notifier);
    final budget = int.tryParse(_budgetController.text);
    controller.setPriceWillingToPay(budget);
    controller.setDescription(_descriptionController.text);
    controller.submit();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(postSeatControllerProvider);
    final controller = ref.read(postSeatControllerProvider.notifier);
    final showErrors = state.hasAttemptedSubmit;

    // Listen for navigation and error events
    ref.listen(postSeatControllerProvider, (prev, next) {
      if (next.createdSeatId != null && !next.hasNavigated) {
        ref.read(postSeatControllerProvider.notifier).markNavigated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.seatRequestCreated),
            backgroundColor: colorScheme.primary,
          ),
        );

        final offerKey = OfferKey(OfferKind.seat, next.createdSeatId!);
        ref.invalidate(offerDetailProvider(offerKey));
        ref.invalidate(myOffersProvider);
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
                        value: state.count,
                        min: 1,
                        max: 8,
                        onChanged: controller.setCount,
                        label: context.l10n.passengersNeeded,
                        errorText: showErrors ? state.countError : null,
                      ),
                      AppTextField(
                        controller: _budgetController,
                        label: context.l10n.budgetOptional,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        suffixText: 'PLN',
                        errorText: showErrors ? state.priceError : null,
                      ),
                      AppTextField(
                        controller: _descriptionController,
                        label: context.l10n.descriptionOptional,
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
          child: Text(context.l10n.postSeatRequest),
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
