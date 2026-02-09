import 'package:flutter/material.dart';

import '../../domain/offer_ui_model.dart';
import 'contact_user_button.dart';

/// Sticky bottom bar for offer details screen with contact button.
class OfferBottomBar extends StatelessWidget {
  final OfferUiModel offer;

  const OfferBottomBar({super.key, required this.offer});

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
        child: SizedBox(
          width: double.infinity,
          child: ContactUserButton(user: offer.user!),
        ),
      ),
    );
  }
}
