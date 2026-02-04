import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final String label;
  final bool isVerified;
  final VoidCallback? onTap;

  const VerificationBadge({
    super.key,
    required this.label,
    required this.isVerified,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isVerified ? Colors.green : theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.verified : Icons.help_outline,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
