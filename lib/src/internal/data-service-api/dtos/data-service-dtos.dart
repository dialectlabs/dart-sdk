import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'data-service-dtos.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateDialectCommand {
  @JsonKey(name: "members")
  final List<PostMemberDto> members;
  @JsonKey(name: "encrypted")
  final bool encrypted;
  CreateDialectCommand({required this.members, required this.encrypted});

  factory CreateDialectCommand.fromJson(Map<String, dynamic> json) =>
      _$CreateDialectCommandFromJson(json);
  Map<String, dynamic> toJson() => _$CreateDialectCommandToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DialectAccountDto {
  @JsonKey(name: "publicKey")
  final String publicKey;
  @JsonKey(name: "dialect")
  final DialectDto dialect;

  DialectAccountDto({required this.publicKey, required this.dialect});

  factory DialectAccountDto.fromJson(Map<String, dynamic> json) =>
      _$DialectAccountDtoFromJson(json);
  Map<String, dynamic> toJson() => _$DialectAccountDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DialectDto {
  @JsonKey(name: "members")
  final List<MemberDto> members;
  @JsonKey(name: "messages")
  final List<MessageDto> messages;
  @JsonKey(name: "nextMessageIdx")
  final num nextMessageIdx;
  @JsonKey(name: "lastMessageTimestamp")
  final int lastMessageTimestamp;
  @JsonKey(name: "encrypted")
  final bool encrypted;

  DialectDto(
      {required this.members,
      required this.messages,
      required this.nextMessageIdx,
      required this.lastMessageTimestamp,
      required this.encrypted});

  factory DialectDto.fromJson(Map<String, dynamic> json) =>
      _$DialectDtoFromJson(json);

  DialectDto.fromPostMembers(
      {required List<PostMemberDto> postMembers,
      required this.messages,
      required this.nextMessageIdx,
      required this.lastMessageTimestamp,
      required this.encrypted})
      : members = postMembers
            .map((m) => MemberDto(publicKey: m.publicKey, scopes: m.scopes))
            .toList();

  @JsonKey(ignore: true)
  @override
  int get hashCode => JsonEncoder().convert(toJson()).hashCode;

  @override
  bool operator ==(covariant DialectDto other) {
    return members == other.members &&
        messages == other.messages &&
        nextMessageIdx == other.nextMessageIdx &&
        lastMessageTimestamp == other.lastMessageTimestamp &&
        encrypted == other.encrypted;
  }

  Map<String, dynamic> toJson() => _$DialectDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MemberDto {
  @JsonKey(name: "publicKey")
  final String publicKey;
  @JsonKey(name: "scopes")
  final List<MemberScopeDto> scopes;

  MemberDto({required this.publicKey, required this.scopes});

  factory MemberDto.fromJson(Map<String, dynamic> json) =>
      _$MemberDtoFromJson(json);

  @JsonKey(ignore: true)
  @override
  int get hashCode => JsonEncoder().convert(toJson()).hashCode;

  @override
  bool operator ==(covariant MemberDto other) {
    return scopes == other.scopes && publicKey == other.publicKey;
  }

  Map<String, dynamic> toJson() => _$MemberDtoToJson(this);
}

enum MemberScopeDto {
  @JsonValue(MemberScopeDtoValues.admin)
  admin,
  @JsonValue(MemberScopeDtoValues.write)
  write
}

class MemberScopeDtoValues {
  static const String admin = "ADMIN";
  static const String write = "WRITE";
}

@JsonSerializable()
class MessageDto {
  @JsonKey(name: "owner")
  final String owner;
  @JsonKey(name: "text")
  final List<int> text;
  @JsonKey(name: "timestamp")
  final int timestamp;

  MessageDto(
      {required this.owner, required this.text, required this.timestamp});

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PostMemberDto {
  @JsonKey(name: "publicKey")
  final String publicKey;
  @JsonKey(name: "scopes")
  final List<MemberScopeDto> scopes;
  PostMemberDto({required this.publicKey, required this.scopes});

  factory PostMemberDto.fromJson(Map<String, dynamic> json) =>
      _$PostMemberDtoFromJson(json);

  @JsonKey(ignore: true)
  @override
  int get hashCode => JsonEncoder().convert(toJson()).hashCode;

  @override
  bool operator ==(covariant PostMemberDto other) {
    return publicKey == other.publicKey && scopes == other.scopes;
  }

  Map<String, dynamic> toJson() => _$PostMemberDtoToJson(this);
}

extension MemberScopeDtoExt on MemberScopeDto {
  String get value {
    switch (this) {
      case MemberScopeDto.write:
        return MemberScopeDtoValues.write;
      case MemberScopeDto.admin:
        return MemberScopeDtoValues.admin;
    }
  }

  static MemberScopeDto? find(String value) {
    for (var val in MemberScopeDto.values) {
      if (val.value == value) {
        return val;
      }
    }
    return null;
  }
}
