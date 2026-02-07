import 'package:freezed_annotation/freezed_annotation.dart';

import 'peer_user_dto.dart';

part 'conversation_dto.freezed.dart';
part 'conversation_dto.g.dart';

@freezed
sealed class ConversationDto with _$ConversationDto {
  const factory ConversationDto({
    required String id,
    required String topicKey,
    required PeerUserDto peerUser,
    String? lastMessage,
    DateTime? lastMessageAt,
    @Default(0) int unreadCount,
  }) = _ConversationDto;

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);
}
