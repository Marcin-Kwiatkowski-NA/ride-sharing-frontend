import 'package:flutter/material.dart';

import '../../domain/offer_ui_model.dart';
import 'offer_section.dart';

/// Cost & capacity section showing price and available seats/capacity.
class OfferMoneyCountSection extends StatelessWidget {
  final OfferUiModel offer;

  const OfferMoneyCountSection({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OfferSection(
      title: 'COST & SEATS',
      child: Row(
        children: [
          Expanded(
            child: InfoTile(
              icon: Icons.payments_outlined,
              label: 'Price per seat',
              value: offer.priceDisplay,
              valueColor: offer.hasPrice ? colorScheme.primary : null,
            ),
          ),
          Container(width: 1, height: 48, color: colorScheme.outlineVariant),
          Expanded(
            child: InfoTile(
              icon: Icons.event_seat_outlined,
              label: 'Available',
              value: offer.capacityDisplay,
            ),
          ),
        ],
      ),
    );
  }
}
