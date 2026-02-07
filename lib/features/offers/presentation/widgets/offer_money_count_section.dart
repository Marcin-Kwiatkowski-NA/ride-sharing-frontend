import 'package:flutter/material.dart';

import '../../domain/offer_ui_model.dart';
import 'offer_section.dart';

/// Cost & capacity section showing money and count metrics.
class OfferMoneyCountSection extends StatelessWidget {
  final OfferUiModel offer;

  const OfferMoneyCountSection({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OfferSection(
      title: 'COST & CAPACITY',
      child: Row(
        children: [
          Expanded(
            child: InfoTile(
              icon: Icons.payments_outlined,
              label: offer.moneyLabel,
              value: offer.moneyValue,
              valueColor: offer.moneyHighlight ? colorScheme.primary : null,
            ),
          ),
          Container(width: 1, height: 48, color: colorScheme.outlineVariant),
          Expanded(
            child: InfoTile(
              icon: offer.countIcon,
              label: offer.countLabel,
              value: offer.countDisplay,
            ),
          ),
        ],
      ),
    );
  }
}
