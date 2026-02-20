/// Delivery status of a chat message.
///
/// [pending] and [failed] are frontend-only states.
/// [sent], [delivered], and [read] map to backend status strings.
enum MessageStatus {
  pending,
  sent,
  delivered,
  read,
  failed;

  /// Parse a backend status string into a [MessageStatus].
  static MessageStatus fromBackend(String status) => switch (status) {
        'SENT' => MessageStatus.sent,
        'DELIVERED' => MessageStatus.delivered,
        'READ' => MessageStatus.read,
        _ => MessageStatus.sent,
      };

  /// Whether this status is lower than [other] in the delivery progression.
  bool operator <(MessageStatus other) => index < other.index;
}
