import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/launchers.dart';
import '../../../../routes/app_router.dart';
import '../../../chat/data/chat_repository.dart';
import '../../../chat/presentation/navigation/chat_arguments.dart';
import '../../data/dto/ride_enums.dart';
import '../../domain/ride_ui_model.dart';

/// Shows the contact methods bottom sheet.
Future<void> showContactMethodsSheet(
  BuildContext context,
  RideUiModel ride,
) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _SourceAwareContactSheet(ride: ride),
  );
}

/// Modal bottom sheet displaying source-aware contact options.
///
/// INTERNAL rides show: "Message in app" (if eligible), Call, Email
/// EXTERNAL rides show: Facebook, Call, Email
class _SourceAwareContactSheet extends ConsumerStatefulWidget {
  final RideUiModel ride;

  const _SourceAwareContactSheet({required this.ride});

  @override
  ConsumerState<_SourceAwareContactSheet> createState() =>
      _SourceAwareContactSheetState();
}

class _SourceAwareContactSheetState
    extends ConsumerState<_SourceAwareContactSheet> {
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return data['detail'] as String? ?? 'Could not start conversation';
      }
    }
    return 'Could not start conversation';
  }

  Future<void> _openInAppChat() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final conversation =
          await ref.read(chatRepositoryProvider).getOrCreateConversation(
                rideId: widget.ride.id,
                driverId: widget.ride.driverId!,
              );

      if (!mounted) return;
      Navigator.pop(context);
      AppRouter.navigateTo(
        context,
        AppRoutes.chat,
        arguments: ChatArguments(conversationId: conversation.id),
      );
    } catch (e) {
      if (!mounted) return;
      // Get messenger before popping (context becomes invalid after pop)
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(_extractErrorMessage(e)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _launchContactMethod(ContactMethodUi method) async {
    Navigator.pop(context);

    final success = await _launch(method);
    if (!success && mounted) {
      _showError(_getErrorMessage(method.type));
    }
  }

  Future<bool> _launch(ContactMethodUi method) async {
    switch (method.type) {
      case ContactType.phone:
        return Launchers.makePhoneCall(method.value);
      case ContactType.facebookLink:
        return Launchers.openUrl(method.value);
      case ContactType.email:
        return Launchers.sendEmail(method.value);
    }
  }

  String _getErrorMessage(ContactType type) {
    switch (type) {
      case ContactType.phone:
        return 'Could not make phone call';
      case ContactType.facebookLink:
        return 'Could not open link';
      case ContactType.email:
        return 'Could not open email client';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ride = widget.ride;

    // Build list of contact options based on ride source
    final options = <Widget>[];

    if (ride.isInternal) {
      // INTERNAL rides
      if (ride.canUseInAppChat) {
        options.add(
          ListTile(
            leading: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chat_outlined),
            title: const Text('Message in app'),
            subtitle: Text('Chat with ${ride.driverDisplayName}'),
            enabled: !_isLoading,
            onTap: _openInAppChat,
          ),
        );
      }

      // Phone option
      final phoneContact = ride.contactMethods
          .where((c) => c.type == ContactType.phone)
          .firstOrNull;
      if (phoneContact != null) {
        options.add(
          ListTile(
            leading: Icon(phoneContact.icon),
            title: Text(phoneContact.label),
            subtitle: Text(phoneContact.preview),
            onTap: () => _launchContactMethod(phoneContact),
          ),
        );
      }

      // Email option
      final emailContact = ride.contactMethods
          .where((c) => c.type == ContactType.email)
          .firstOrNull;
      if (emailContact != null) {
        options.add(
          ListTile(
            leading: Icon(emailContact.icon),
            title: Text(emailContact.label),
            subtitle: Text(emailContact.preview),
            onTap: () => _launchContactMethod(emailContact),
          ),
        );
      }
    } else {
      // EXTERNAL rides
      // Facebook option first
      final facebookContact = ride.contactMethods
          .where((c) => c.type == ContactType.facebookLink)
          .firstOrNull;
      if (facebookContact != null) {
        options.add(
          ListTile(
            leading: Icon(facebookContact.icon),
            title: Text(facebookContact.label),
            subtitle: Text(facebookContact.preview),
            onTap: () => _launchContactMethod(facebookContact),
          ),
        );
      }

      // Phone option
      final phoneContact = ride.contactMethods
          .where((c) => c.type == ContactType.phone)
          .firstOrNull;
      if (phoneContact != null) {
        options.add(
          ListTile(
            leading: Icon(phoneContact.icon),
            title: Text(phoneContact.label),
            subtitle: Text(phoneContact.preview),
            onTap: () => _launchContactMethod(phoneContact),
          ),
        );
      }

      // Email option
      final emailContact = ride.contactMethods
          .where((c) => c.type == ContactType.email)
          .firstOrNull;
      if (emailContact != null) {
        options.add(
          ListTile(
            leading: Icon(emailContact.icon),
            title: Text(emailContact.label),
            subtitle: Text(emailContact.preview),
            onTap: () => _launchContactMethod(emailContact),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contact driver',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Contact options
          if (options.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No contact options available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            )
          else
            ...options,

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );
  }
}
