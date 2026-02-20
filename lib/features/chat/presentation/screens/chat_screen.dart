import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/network/stomp_connection_state.dart';
import '../../../../core/network/stomp_connection_state_provider.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../domain/message_status.dart';
import '../../domain/message_ui_model.dart';
import '../providers/chat_thread_provider.dart';

/// Chat screen for viewing and sending messages in a conversation.
///
/// HAS Scaffold — this is a pushed route.
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String? peerName;
  final String? topicKey;

  const ChatScreen({
    super.key,
    required this.conversationId,
    this.peerName,
    this.topicKey,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // In a reversed list, offset > 0 means user scrolled up (away from newest)
    final shouldShow =
        _scrollController.hasClients && _scrollController.offset > 200;
    if (shouldShow != _showScrollToBottom) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref
        .read(chatThreadProvider(widget.conversationId).notifier)
        .sendMessage(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatThreadProvider(widget.conversationId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName ?? context.l10n.chatTitle),
        actions: const [_ConnectionIndicator()],
      ),
      body: PageLayout.chat(
        child: Column(
          children: [
            Expanded(child: _buildContent(theme, state)),
            _MessageComposer(
              controller: _textController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
      floatingActionButton: _showScrollToBottom
          ? Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton.small(
                onPressed: _scrollToBottom,
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            )
          : null,
    );
  }

  Widget _buildContent(ThemeData theme, ChatThreadState state) {
    if (state.isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(context.l10n.couldNotLoadMessages),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => ref
                  .read(chatThreadProvider(widget.conversationId).notifier)
                  .refresh(),
              child: Text(context.l10n.retry),
            ),
          ],
        ),
      );
    }

    if (state.messages.isEmpty) {
      return Center(
        child: Text(
          context.l10n.sendMessageToStart,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    return _MessagesList(
      conversationId: widget.conversationId,
      messages: state.messages,
      scrollController: _scrollController,
      hasMoreEarlier: state.hasMoreEarlier,
      isLoadingEarlier: state.isLoadingEarlier,
      onLoadEarlier: () => ref
          .read(chatThreadProvider(widget.conversationId).notifier)
          .loadEarlier(),
    );
  }
}

// -- Messages list (reversed) ------------------------------------------------

class _MessagesList extends ConsumerWidget {
  final String conversationId;
  final List<MessageUiModel> messages;
  final ScrollController scrollController;
  final bool hasMoreEarlier;
  final bool isLoadingEarlier;
  final VoidCallback onLoadEarlier;

  const _MessagesList({
    required this.conversationId,
    required this.messages,
    required this.scrollController,
    required this.hasMoreEarlier,
    required this.isLoadingEarlier,
    required this.onLoadEarlier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // +1 for the load-earlier button at the top (last index in reversed list)
    final itemCount = messages.length + (hasMoreEarlier ? 1 : 0);

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // In a reversed list, index 0 = newest message
        if (hasMoreEarlier && index == itemCount - 1) {
          return _LoadEarlierButton(
            isLoading: isLoadingEarlier,
            onPressed: onLoadEarlier,
          );
        }

        // Reversed index: messages[last - index]
        final messageIndex = messages.length - 1 - index;
        final message = messages[messageIndex];
        return _MessageBubble(
          message: message,
          onRetry: message.status == MessageStatus.failed
              ? () => ref
                  .read(chatThreadProvider(conversationId).notifier)
                  .retryMessage(message.id)
              : null,
        );
      },
    );
  }
}

// -- Load earlier button -----------------------------------------------------

class _LoadEarlierButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoadEarlierButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : TextButton(
                onPressed: onPressed,
                child: Text(context.l10n.chatLoadEarlier),
              ),
      ),
    );
  }
}

// -- Message bubble ----------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final MessageUiModel message;
  final VoidCallback? onRetry;

  const _MessageBubble({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFromUser = message.isFromCurrentUser;

    final bubble = Align(
      alignment: isFromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isFromUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isFromUser
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.timeDisplay,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isFromUser
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                        : theme.colorScheme.outline,
                  ),
                ),
                if (message.status != null) ...[
                  const SizedBox(width: 4),
                  _StatusIndicator(
                    status: message.status!,
                    isFromUser: isFromUser,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (onRetry != null) {
      return GestureDetector(onTap: onRetry, child: bubble);
    }
    return bubble;
  }
}

// -- Status indicator --------------------------------------------------------

class _StatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final bool isFromUser;

  const _StatusIndicator({required this.status, required this.isFromUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (IconData icon, Color color) = switch (status) {
      MessageStatus.pending => (
          Icons.access_time,
          isFromUser
              ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
              : theme.colorScheme.outline,
        ),
      MessageStatus.sent => (
          Icons.check,
          isFromUser
              ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
              : theme.colorScheme.outline,
        ),
      MessageStatus.delivered => (
          Icons.done_all,
          isFromUser
              ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
              : theme.colorScheme.outline,
        ),
      MessageStatus.read => (
          Icons.done_all,
          theme.colorScheme.primary,
        ),
      MessageStatus.failed => (
          Icons.error_outline,
          theme.colorScheme.error,
        ),
    };

    return Icon(icon, size: 14, color: color);
  }
}

// -- Connection indicator ----------------------------------------------------

class _ConnectionIndicator extends ConsumerWidget {
  const _ConnectionIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connAsync = ref.watch(stompConnectionStateProvider);
    final connState =
        connAsync.value ?? StompConnectionState.disconnected;

    final color = switch (connState) {
      StompConnectionState.connected => Colors.green,
      StompConnectionState.connecting => Colors.orange,
      StompConnectionState.disconnected => Colors.red,
      StompConnectionState.error => Colors.red,
    };

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// -- Message composer --------------------------------------------------------

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageComposer({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        8 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: context.l10n.typeAMessage,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return IconButton.filled(
                onPressed:
                    controller.text.trim().isEmpty ? null : onSend,
                icon: const Icon(Icons.send),
              );
            },
          ),
        ],
      ),
    );
  }
}
