import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/launchers.dart';
import '../../../../routes/routes.dart';
import '../../../chat/data/chat_repository.dart';
import '../../data/offer_enums.dart';
import '../../domain/offer_models.dart';

/// Shows the contact methods bottom sheet.
Future<void> showContactUserSheet(BuildContext context, OfferUserUi user) {
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _SourceAwareContactSheet(user: user),
  );
}

class _SourceAwareContactSheet extends ConsumerStatefulWidget {
  final OfferUserUi user;

  const _SourceAwareContactSheet({required this.user});

  @override
  ConsumerState<_SourceAwareContactSheet> createState() =>
      _SourceAwareContactSheetState();
}

class _SourceAwareContactSheetState
    extends ConsumerState<_SourceAwareContactSheet> {
  bool _isLoading = false;

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
      final user = widget.user;
      final conversation = await ref
          .read(chatRepositoryProvider)
          .getOrCreateConversation(
            rideId: user.chatContext.id,
            driverId: user.userId!,
          );

      if (!mounted) return;
      Navigator.pop(context);
      context.pushNamed(
        RouteNames.chat,
        pathParameters: {'conversationId': conversation.id},
      );
    } catch (e) {
      if (!mounted) return;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(method.type)),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    final user = widget.user;

    final options = <Widget>[];

    // In-app chat (only for internal offers with userId)
    if (user.canUseInAppChat) {
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
          subtitle: Text('Chat with ${user.displayName}'),
          enabled: !_isLoading,
          onTap: _openInAppChat,
        ),
      );
    }

    // External contact methods — order by: phone, facebook, email
    // But for external offers, facebook comes first
    if (user.canUseInAppChat) {
      // Internal: phone then email (facebook not typical for internal)
      _addContactByType(options, user, ContactType.phone);
      _addContactByType(options, user, ContactType.email);
    } else {
      // External: facebook first, then phone, then email
      _addContactByType(options, user, ContactType.facebookLink);
      _addContactByType(options, user, ContactType.phone);
      _addContactByType(options, user, ContactType.email);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Contact', style: theme.textTheme.titleLarge),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),

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

          SizedBox(height: MediaQuery.viewPaddingOf(context).bottom),
        ],
      ),
    );
  }

  void _addContactByType(
    List<Widget> options,
    OfferUserUi user,
    ContactType type,
  ) {
    final contact = user.contactMethods
        .where((c) => c.type == type)
        .firstOrNull;
    if (contact != null) {
      options.add(
        ListTile(
          leading: Icon(contact.icon),
          title: Text(contact.label),
          subtitle: Text(contact.preview),
          onTap: () => _launchContactMethod(contact),
        ),
      );
    }
  }
}
