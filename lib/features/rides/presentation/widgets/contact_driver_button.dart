import 'package:flutter/material.dart';

import '../../domain/ride_ui_model.dart';
import 'contact_methods_bottom_sheet.dart';

/// Button that opens the contact methods bottom sheet.
///
/// Shows "No contact available" when disabled.
/// Use [useTonalStyle] for in-card appearance vs bottom bar.
class ContactDriverButton extends StatelessWidget {
  final RideUiModel ride;
  final bool useTonalStyle;

  const ContactDriverButton({
    super.key,
    required this.ride,
    this.useTonalStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!ride.hasAnyContactMethod) {
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.phone_disabled),
        label: const Text('No contact available'),
      );
    }

    if (useTonalStyle) {
      return FilledButton.tonalIcon(
        onPressed: () => showContactMethodsSheet(context, ride),
        icon: const Icon(Icons.phone),
        label: const Text('Contact driver'),
      );
    }

    return FilledButton.icon(
      onPressed: () => showContactMethodsSheet(context, ride),
      icon: const Icon(Icons.phone),
      label: const Text('Contact driver'),
    );
  }
}
