import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../presentation/widgets/verification_badge.dart';

class VerificationChipsSection extends StatelessWidget {
  final bool isEmailVerified;
  final bool isPhoneVerified;

  const VerificationChipsSection({
    super.key,
    required this.isEmailVerified,
    required this.isPhoneVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          VerificationBadge(
            label: context.l10n.phoneLabel,
            isVerified: isPhoneVerified,
          ),
          VerificationBadge(
            label: context.l10n.emailLabel,
            isVerified: isEmailVerified,
          ),
        ],
      ),
    );
  }
}
