import 'package:flutter/foundation.dart';

/// UI-ready model for a conversation in the inbox list.
@immutable
class ConversationUiModel {
  final String id;
  final String peerUserName;
  final String? peerAvatarUrl;
  final String lastMessagePreview;
  final String timeAgo;
  final int unreadCount;
  final bool hasMessages;

  const ConversationUiModel({
    required this.id,
    required this.peerUserName,
    this.peerAvatarUrl,
    required this.lastMessagePreview,
    required this.timeAgo,
    required this.unreadCount,
    required this.hasMessages,
  });
}
