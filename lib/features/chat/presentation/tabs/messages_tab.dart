import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../../../routes/routes.dart';
import '../../domain/chat_route_extra.dart';
import '../../domain/conversation_ui_model.dart';
import '../providers/inbox_provider.dart';

/// Messages tab content for the bottom navigation.
///
/// NO Scaffold — MainLayout owns the shell.
class MessagesTab extends ConsumerWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(inboxProvider);
    final theme = Theme.of(context);

    return PageLayout(
      safeArea: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            child: Text(
              context.l10n.messagesTitle,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          Expanded(
            child: conversationsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorWithRetry(
                error: e,
                onRetry: () => ref.invalidate(inboxProvider),
              ),
              data: (conversations) => conversations.isEmpty
                  ? const _EmptyMessages()
                  : _ConversationsList(
                      conversations: conversations,
                      onRefresh: () async {
                        ref.invalidate(inboxProvider);
                        await ref.read(inboxProvider.future);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWithRetry extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorWithRetry({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text(context.l10n.couldNotLoadMessages),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text(context.l10n.retry),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noMessagesYet,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.startConversation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationsList extends StatelessWidget {
  final List<ConversationUiModel> conversations;
  final Future<void> Function() onRefresh;

  const _ConversationsList({
    required this.conversations,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return _ConversationTile(conversation: conversation);
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationUiModel conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversation.unreadCount > 0;

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          conversation.peerUserName.isNotEmpty
              ? conversation.peerUserName[0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(
        conversation.peerUserName,
        style: hasUnread
            ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
            : null,
      ),
      subtitle: Text(
        conversation.lastMessagePreview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (conversation.timeAgo.isNotEmpty)
            Text(
              conversation.timeAgo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          if (hasUnread) ...[
            const SizedBox(width: 8),
            Badge(
              label: Text('${conversation.unreadCount}'),
              backgroundColor: theme.colorScheme.primary,
            ),
          ],
        ],
      ),
      onTap: () {
        context.pushNamed(
          RouteNames.chat,
          pathParameters: {'conversationId': conversation.id},
          extra: ChatRouteExtra(
            peerName: conversation.peerUserName,
            topicKey: conversation.topicKey,
          ),
        );
      },
    );
  }
}
