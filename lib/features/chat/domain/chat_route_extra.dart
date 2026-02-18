import 'package:flutter/foundation.dart';

/// Extra data passed to the chat route via GoRouter's `state.extra`.
@immutable
class ChatRouteExtra {
  final String? peerName;
  final String? topicKey;

  const ChatRouteExtra({this.peerName, this.topicKey});
}
