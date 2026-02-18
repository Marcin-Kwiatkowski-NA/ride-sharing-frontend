import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/utils/launchers.dart';
import '../../../../routes/routes.dart';
import '../../../chat/data/chat_repository.dart';
import '../../../chat/domain/chat_route_extra.dart';
import '../../data/offer_enums.dart';
import '../../domain/offer_models.dart';
import '../../domain/offer_ui_model.dart';

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
      final offerKey = OfferKey(user.chatContext.kind, user.chatContext.id);
      final topicKey = topicKeyForOffer(offerKey);

      final response = await ref
          .read(chatRepositoryProvider)
          .openConversation(
            topicKey: topicKey,
            peerUserId: user.userId!,
          );

      if (!mounted) return;
      Navigator.pop(context);
      context.pushNamed(
        RouteNames.chat,
        pathParameters: {'conversationId': response.conversationId},
        extra: ChatRouteExtra(
          peerName: user.displayName,
          topicKey: topicKey,
        ),
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

  Future<void> _launchAction(
    Future<bool> Function() action,
    String errorMessage,
  ) async {
    Navigator.pop(context);

    final success = await action();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    final l10n = context.l10n;
    final contact = user.contactMethods
        .where((c) => c.type == type)
        .firstOrNull;
    if (contact == null) return;

    switch (type) {
      case ContactType.phone:
        options.add(
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(l10n.callLabel),
            subtitle: Text(contact.preview),
            onTap: () => _launchAction(
              () => Launchers.makePhoneCall(contact.value),
              l10n.couldNotOpenDialer,
            ),
          ),
        );
        options.add(
          ListTile(
            leading: const Icon(Icons.sms_outlined),
            title: Text(l10n.sendSmsLabel),
            subtitle: Text(contact.preview),
            onTap: () => _launchAction(
              () => Launchers.sendSms(contact.value),
              l10n.couldNotOpenMessagingApp,
            ),
          ),
        );
      case ContactType.facebookLink:
        options.add(
          ListTile(
            leading: Icon(contact.icon),
            title: Text(l10n.openFacebookPost),
            subtitle: Text(contact.preview),
            onTap: () => _launchAction(
              () => Launchers.openUrl(contact.value),
              l10n.couldNotOpenLink,
            ),
          ),
        );
      case ContactType.email:
        options.add(
          ListTile(
            leading: Icon(contact.icon),
            title: Text(l10n.sendEmail),
            subtitle: Text(contact.preview),
            onTap: () => _launchAction(
              () => Launchers.sendEmail(contact.value),
              l10n.couldNotOpenEmailClient,
            ),
          ),
        );
    }
  }
}
