import 'package:flutter/foundation.dart';

/// Typed route arguments for the chat screen.
@immutable
class ChatArguments {
  final String conversationId;

  const ChatArguments({required this.conversationId});
}
