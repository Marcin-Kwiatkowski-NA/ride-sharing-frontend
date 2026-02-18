import 'package:intl/intl.dart';

import '../data/dto/conversation_dto.dart';
import '../data/dto/message_dto.dart';
import 'conversation_ui_model.dart';
import 'message_ui_model.dart';

/// Pure function mapper: Chat DTOs -> UI models.
class ChatPresentation {
  static final _timeFormat = DateFormat('HH:mm');

  /// Convert ConversationDto to UI model.
  static ConversationUiModel toConversationUiModel(ConversationDto dto) {
    final lastMessagePreview = dto.lastMessage ?? 'No messages yet';
    final timeAgo =
        dto.lastMessageAt != null ? _formatTimeAgo(dto.lastMessageAt!) : '';

    return ConversationUiModel(
      id: dto.id,
      topicKey: dto.topicKey,
      peerUserName: dto.peerUser.displayName,
      peerAvatarUrl: dto.peerUser.avatarUrl,
      lastMessagePreview: lastMessagePreview,
      timeAgo: timeAgo,
      unreadCount: dto.unreadCount,
      hasMessages: dto.lastMessage != null,
    );
  }

  /// Convert list of ConversationDtos to UI models.
  static List<ConversationUiModel> toConversationUiModels(
    List<ConversationDto> dtos,
  ) {
    return dtos.map(toConversationUiModel).toList();
  }

  /// Convert MessageDto to UI model.
  ///
  /// When [currentUserId] is provided, ownership is determined by comparing
  /// [MessageDto.senderId] against it (used for STOMP messages where
  /// `isMine` is always false). Otherwise falls back to [MessageDto.isMine]
  /// (set correctly by the REST API).
  static MessageUiModel toMessageUiModel(
    MessageDto dto, {
    int? currentUserId,
  }) {
    final isFromCurrentUser = currentUserId != null
        ? dto.senderId == currentUserId
        : dto.isMine;
    return MessageUiModel(
      id: dto.id,
      text: dto.body,
      timeDisplay: _timeFormat.format(dto.createdAt),
      isFromCurrentUser: isFromCurrentUser,
    );
  }

  /// Convert list of MessageDtos to UI models.
  static List<MessageUiModel> toMessageUiModels(
    List<MessageDto> dtos, {
    int? currentUserId,
  }) {
    return dtos
        .map((d) => toMessageUiModel(d, currentUserId: currentUserId))
        .toList();
  }

  /// Format time as relative "time ago" string.
  static String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
