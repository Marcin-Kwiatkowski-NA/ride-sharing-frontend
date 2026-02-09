import 'package:flutter/material.dart';

import '../../domain/offer_models.dart';
import '../helpers/offer_details_strings.dart';
import 'contact_user_sheet.dart';

/// Button that opens the contact methods bottom sheet.
///
/// Shows "No contact available" when the user has no contact actions.
/// Use [useTonalStyle] for in-card appearance vs bottom bar.
class ContactUserButton extends StatelessWidget {
  final OfferUserUi user;
  final bool useTonalStyle;

  const ContactUserButton({
    super.key,
    required this.user,
    this.useTonalStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = OfferDetailsStrings(context).contactLabel(user: user);

    if (!user.hasAnyContactAction) {
      return FilledButton.icon(
        onPressed: null,
        icon: const Icon(Icons.phone_disabled),
        label: Text(label),
      );
    }

    if (useTonalStyle) {
      return FilledButton.tonalIcon(
        onPressed: () => showContactUserSheet(context, user),
        icon: const Icon(Icons.phone),
        label: Text(label),
      );
    }

    return FilledButton.icon(
      onPressed: () => showContactUserSheet(context, user),
      icon: const Icon(Icons.phone),
      label: Text(label),
    );
  }
}
