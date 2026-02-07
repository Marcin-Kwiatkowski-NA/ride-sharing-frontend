import 'package:flutter/material.dart';

import '../../domain/offer_ui_model.dart';
import 'contact_user_button.dart';

/// Bottom bar for offer details screen with contact button.
class OfferBottomBar extends StatelessWidget {
  final OfferUiModel offer;

  const OfferBottomBar({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (offer.user == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ContactUserButton(user: offer.user!),
      ),
    );
  }
}
