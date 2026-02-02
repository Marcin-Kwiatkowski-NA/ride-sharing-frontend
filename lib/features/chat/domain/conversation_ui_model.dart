import 'package:flutter/foundation.dart';

/// UI-ready model for a conversation in the inbox list.
@immutable
class ConversationUiModel {
  final String id;
  final int rideId;
  final int driverId;
  final String driverName;
  final String lastMessagePreview;
  final String timeAgo;
  final int unreadCount;
  final bool hasMessages;

  const ConversationUiModel({
    required this.id,
    required this.rideId,
    required this.driverId,
    required this.driverName,
    required this.lastMessagePreview,
    required this.timeAgo,
    required this.unreadCount,
    required this.hasMessages,
  });
}
