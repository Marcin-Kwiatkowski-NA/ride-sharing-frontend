import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/providers/auth_notifier.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../../routes/routes.dart';
import '../widgets.dart';
import '../widgets/language_selector.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshUserIfNeeded();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshUserIfNeeded();
    }
  }

  void _refreshUserIfNeeded() {
    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      ref.read(authProvider.notifier).refreshUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.profileTitle)),
        body: PageLayout.form(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 100, color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(context.l10n.logInToSeeProfile),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.pushNamed(RouteNames.login);
                  },
                  child: Text(context.l10n.logInSignUp),
                ),
                const SizedBox(height: 32),
                const LanguageSelector(),
              ],
            ),
          ),
        ),
      );
    }

    return _ProfileDashboard(user: user);
  }
}

class _ProfileDashboard extends ConsumerWidget {
  final UserProfile user;

  const _ProfileDashboard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: PageLayout(
        child: CustomScrollView(
          slivers: [
            // SliverAppBar with gradient background
            SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      AvatarCircle(
                        imageUrl: user.avatarUrl,
                        displayName: user.displayName,
                        radius: 50,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.displayName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Trust badges section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.trustAndVerification,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      VerificationBadge(
                        label: context.l10n.emailLabel,
                        isVerified: user.isEmailVerified,
                        onTap: user.isEmailVerified
                            ? null
                            : () => _handleResendVerification(context, ref),
                      ),
                      VerificationBadge(
                        label: context.l10n.phoneLabel,
                        isVerified: user.isPhoneVerified,
                        onTap: user.isPhoneVerified
                            ? null
                            : () => _showComingSoon(context, context.l10n.phoneVerification),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Profile completeness card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileCompletenessCard(
                user: user,
                onCompleteProfile: () {
                  context.pushNamed(RouteNames.editProfile);
                },
              ),
            ),
          ),

          // Stats section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.statistics,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsCard(
                          icon: Icons.directions_car,
                          value: user.stats.ridesGiven.toString(),
                          label: context.l10n.ridesGiven,
                          accentColor: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatsCard(
                          icon: Icons.airline_seat_recline_normal,
                          value: user.stats.ridesTaken.toString(),
                          label: context.l10n.ridesTaken,
                          accentColor: theme.colorScheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: StatsCard(
                          icon: Icons.star,
                          value: user.stats.ratingCount > 0
                              ? user.stats.ratingAvg.toStringAsFixed(1)
                              : '-',
                          label: context.l10n.rating,
                          accentColor: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Actions card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    ProfileActionTile(
                      icon: Icons.edit,
                      title: context.l10n.editProfile,
                      subtitle: context.l10n.updatePersonalInfo,
                      onTap: () {
                        context.pushNamed(RouteNames.editProfile);
                      },
                    ),
                    const Divider(height: 1),
                    ProfileActionTile(
                      icon: Icons.history,
                      title: context.l10n.myOffers,
                      subtitle: context.l10n.viewRideHistory,
                      onTap: () => context.goNamed(RouteNames.myOffers),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Language selector
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LanguageSelector(),
            ),
          ),

          // Logout button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context, ref),
                  icon: const Icon(Icons.logout),
                  label: Text(context.l10n.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                ),
              ),
            ),
          ),

          // Delete account button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: () => _handleDeleteAccount(context, ref),
                child: Text(
                  context.l10n.deleteAccount,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ),

          // Bottom spacing
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
        ),
      ),
    );
  }

  Future<void> _handleResendVerification(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(authProvider.notifier).resendVerification();
    if (!context.mounted) return;

    final l10n = context.l10n;
    final message = switch (result) {
      ResendSuccess() => l10n.verificationEmailSent,
      ResendAlreadyVerified() => l10n.emailAlreadyVerified,
      ResendCooldown(:final seconds) => l10n.verificationCooldown(seconds),
      ResendError() => l10n.genericVerificationError,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.comingSoon(feature))),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(l10n.deleteAccountWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: Text(l10n.deleteAccountConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final success = await ref.read(authProvider.notifier).deleteAccount();
    if (!context.mounted) return;

    if (success) {
      context.goNamed(RouteNames.rides);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deleteAccountError)),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) {
      context.goNamed(RouteNames.rides);
    }
  }
}
