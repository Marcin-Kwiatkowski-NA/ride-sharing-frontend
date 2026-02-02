import 'package:flutter/foundation.dart';

/// UI-ready model for a message in the chat thread.
@immutable
class MessageUiModel {
  final String id;
  final String text;
  final String timeDisplay;
  final bool isFromCurrentUser;

  const MessageUiModel({
    required this.id,
    required this.text,
    required this.timeDisplay,
    required this.isFromCurrentUser,
  });
}
