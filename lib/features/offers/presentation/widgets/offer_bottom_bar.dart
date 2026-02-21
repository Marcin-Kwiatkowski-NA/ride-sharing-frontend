import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../booking/domain/booking_mode.dart';
import '../../domain/offer_ui_model.dart';
import 'contact_user_button.dart';
import 'contact_user_sheet.dart';

/// Sticky bottom bar for offer details screen.
///
/// Three modes:
/// - **External ride**: Single Contact button (unchanged)
/// - **Internal + bookable**: Outlined "Contact Driver" + filled "Book Ride"
/// - **Internal + not bookable**: Single Contact button (fallback)
class OfferBottomBar extends StatelessWidget {
  final OfferUiModel offer;

  /// Callback when the user taps "Book Ride" / "Request to Book".
  final VoidCallback? onBookTap;

  const OfferBottomBar({
    super.key,
    required this.offer,
    this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      maintainBottomViewPadding: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final user = offer.user!;
    final isInternal = !offer.isExternalSource;
    final canBook = isInternal && offer.isBookable;

    // External ride or internal but not bookable: contact only
    if (!canBook) {
      return SizedBox(
        width: double.infinity,
        child: ContactUserButton(user: user),
      );
    }

    // Internal + bookable: dual CTA
    final l10n = context.l10n;
    final isInstant = offer.bookingMode == BookingMode.instant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Secondary: Contact Driver
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => showContactUserSheet(context, user),
            icon: const Icon(Icons.chat_outlined, size: 18),
            label: Text(l10n.contactDriver),
          ),
        ),
        const SizedBox(height: 8),
        // Primary: Book Ride / Request to Book
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onBookTap,
            icon: Icon(
              isInstant ? Icons.bolt : Icons.hourglass_top,
              size: 18,
            ),
            label: Text(
              isInstant ? l10n.bookRide : l10n.requestToBook,
            ),
          ),
        ),
      ],
    );
  }
}

