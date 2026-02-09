import 'package:flutter/material.dart';

import '../../../../core/widgets/core_widgets.dart';
import '../domain/public_profile_data.dart';

class ProfileHeaderSection extends StatelessWidget {
  final PublicProfileData profile;

  const ProfileHeaderSection({super.key, required this.profile});

  bool get _isFullyVerified =>
      profile.isEmailVerified && profile.isPhoneVerified;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          // Avatar with optional verified badge
          Hero(
            tag: 'avatar-${profile.userId}',
            child: Stack(
              children: [
                AvatarCircle(
                  imageUrl: profile.avatarUrl,
                  displayName: profile.displayName,
                  radius: 64,
                  backgroundColor: cs.primaryContainer,
                ),
                if (_isFullyVerified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        size: 28,
                        color: cs.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.displayName,
            style: tt.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
