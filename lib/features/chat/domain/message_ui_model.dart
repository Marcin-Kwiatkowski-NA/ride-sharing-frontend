import 'package:flutter/foundation.dart';

import 'message_status.dart';

/// UI-ready model for a message in the chat thread.
@immutable
class MessageUiModel {
  final String id;
  final String text;
  final String timeDisplay;
  final bool isFromCurrentUser;

  /// Delivery status indicator. Null for incoming messages (no indicator shown).
  final MessageStatus? status;

  const MessageUiModel({
    required this.id,
    required this.text,
    required this.timeDisplay,
    required this.isFromCurrentUser,
    this.status,
  });

  /// Create a copy with updated fields.
  MessageUiModel copyWith({
    String? id,
    String? text,
    String? timeDisplay,
    bool? isFromCurrentUser,
    MessageStatus? status,
  }) {
    return MessageUiModel(
      id: id ?? this.id,
      text: text ?? this.text,
      timeDisplay: timeDisplay ?? this.timeDisplay,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
      status: status ?? this.status,
    );
  }
}
