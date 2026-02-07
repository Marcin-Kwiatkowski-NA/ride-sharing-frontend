import 'package:freezed_annotation/freezed_annotation.dart';

part 'peer_user_dto.freezed.dart';
part 'peer_user_dto.g.dart';

@freezed
sealed class PeerUserDto with _$PeerUserDto {
  const factory PeerUserDto({
    required int id,
    required String displayName,
    String? avatarUrl,
  }) = _PeerUserDto;

  factory PeerUserDto.fromJson(Map<String, dynamic> json) =>
      _$PeerUserDtoFromJson(json);
}
