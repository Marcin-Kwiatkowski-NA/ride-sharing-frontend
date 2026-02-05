import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../../domain/conversation_ui_model.dart';
import '../providers/inbox_provider.dart';

/// Messages tab content for the bottom navigation.
///
/// NO Scaffold - MainLayout owns the shell.
class MessagesTab extends ConsumerWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(inboxProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lightweight header (no AppBar, just styled text)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Messages', style: theme.textTheme.headlineSmall),
          ),
          Expanded(
            child: conversationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorWithRetry(
                error: e,
                onRetry: () => ref.invalidate(inboxProvider),
              ),
              data: (conversations) => conversations.isEmpty
                  ? const _EmptyMessages()
                  : _ConversationsList(conversations: conversations),
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
          const Text('Could not load messages'),
          const SizedBox(height: 8),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
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
            'No messages yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation from a ride listing',
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

  const _ConversationsList({required this.conversations});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _ConversationTile(conversation: conversation);
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationUiModel conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          conversation.driverName.isNotEmpty
              ? conversation.driverName[0].toUpperCase()
              : 'D',
        ),
      ),
      title: Text(conversation.driverName),
      subtitle: Text(
        conversation.lastMessagePreview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: conversation.timeAgo.isNotEmpty
          ? Text(
              conversation.timeAgo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            )
          : null,
      onTap: () {
        context.pushNamed(
          RouteNames.chat,
          pathParameters: {'conversationId': conversation.id},
        );
      },
    );
  }
}
