import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/public_profile_data.dart';
import '../providers/public_profile_cache.dart';
import '../widgets/about_section.dart';
import '../widgets/profile_header_section.dart';
import '../widgets/stats_row_section.dart';
import '../widgets/vehicle_section.dart';
import '../widgets/verification_chips_section.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final int userId;
  final PublicProfileData? initialData;

  const PublicProfileScreen({
    super.key,
    required this.userId,
    this.initialData,
  });

  @override
  ConsumerState<PublicProfileScreen> createState() =>
      _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    if (data == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cached =
          ref.read(publicProfileCacheProvider)[widget.userId];
      if (cached == null) {
        ref.read(publicProfileCacheProvider.notifier).put(data);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cached = ref.watch(
      publicProfileCacheProvider.select(
        (cache) => cache[widget.userId],
      ),
    );
    final profile = cached ?? widget.initialData;

    return Scaffold(
      appBar: AppBar(
        title: Text(profile?.displayName ?? 'Profile'),
      ),
      body: profile == null
          ? const _UnavailablePlaceholder()
          : _ProfileBody(profile: profile),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  final PublicProfileData profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileHeaderSection(profile: profile),
          VerificationChipsSection(
            isEmailVerified: profile.isEmailVerified,
            isPhoneVerified: profile.isPhoneVerified,
          ),
          StatsRowSection(profile: profile),
          AboutSection(bio: profile.bio),
          VehicleSection(vehicles: profile.vehicles),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _UnavailablePlaceholder extends StatelessWidget {
  const _UnavailablePlaceholder();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Profile not available',
            style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'This profile cannot be displayed right now.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
