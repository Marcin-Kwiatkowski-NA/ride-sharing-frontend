import 'package:flutter/material.dart';
import 'package:vamigo/core/l10n/l10n_extension.dart';
import 'package:vamigo/core/models/user_profile.dart';

class ProfileCompletenessCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback? onCompleteProfile;

  const ProfileCompletenessCard({
    super.key,
    required this.user,
    this.onCompleteProfile,
  });

  double get _completionPercentage {
    int filled = 0;
    const int total = 5; // displayName, email, phone, bio, avatar

    if (user.displayName.isNotEmpty) filled++;
    if (user.email.isNotEmpty) filled++;
    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) filled++;
    if (user.bio != null && user.bio!.isNotEmpty) filled++;
    if (user.avatarUrl != null) filled++;

    return filled / total;
  }

  String _completionLabel(BuildContext context) {
    final percent = (_completionPercentage * 100).round();
    if (percent >= 100) return context.l10n.profileComplete;
    return context.l10n.percentComplete(percent);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = _completionPercentage;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  progress >= 1.0 ? Icons.check_circle : Icons.account_circle,
                  color: progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.profileCompleteness,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  progress >= 1.0 ? Colors.green : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _completionLabel(context),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (progress < 1.0)
                  TextButton(
                    onPressed: onCompleteProfile,
                    child: Text(context.l10n.complete),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
