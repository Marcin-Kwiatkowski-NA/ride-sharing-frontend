import 'package:flutter/material.dart';

import 'offer_section.dart';

/// Description section for offer details.
class OfferDescriptionSection extends StatelessWidget {
  final String description;

  const OfferDescriptionSection({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OfferSection(
      title: 'DESCRIPTION',
      child: Text(description, style: theme.textTheme.bodyLarge),
    );
  }
}
