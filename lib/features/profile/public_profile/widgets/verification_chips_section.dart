import 'package:flutter/material.dart';

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
            label: 'Phone',
            isVerified: isPhoneVerified,
          ),
          VerificationBadge(
            label: 'Email',
            isVerified: isEmailVerified,
          ),
        ],
      ),
    );
  }
}
