// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data-service-dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDialectCommand _$CreateDialectCommandFromJson(
        Map<String, dynamic> json) =>
    CreateDialectCommand(
      members: (json['members'] as List<dynamic>)
          .map((e) => PostMemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      encrypted: json['encrypted'] as bool,
    );

Map<String, dynamic> _$CreateDialectCommandToJson(
        CreateDialectCommand instance) =>
    <String, dynamic>{
      'members': instance.members.map((e) => e.toJson()).toList(),
      'encrypted': instance.encrypted,
    };

DialectAccountDto _$DialectAccountDtoFromJson(Map<String, dynamic> json) =>
    DialectAccountDto(
      publicKey: json['publicKey'] as String,
      dialect: DialectDto.fromJson(json['dialect'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DialectAccountDtoToJson(DialectAccountDto instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'dialect': instance.dialect.toJson(),
    };

DialectDto _$DialectDtoFromJson(Map<String, dynamic> json) => DialectDto(
      members: (json['members'] as List<dynamic>)
          .map((e) => MemberDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextMessageIdx: json['nextMessageIdx'] as num,
      lastMessageTimestamp: json['lastMessageTimestamp'] as num,
      encrypted: json['encrypted'] as bool,
    );

Map<String, dynamic> _$DialectDtoToJson(DialectDto instance) =>
    <String, dynamic>{
      'members': instance.members.map((e) => e.toJson()).toList(),
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'nextMessageIdx': instance.nextMessageIdx,
      'lastMessageTimestamp': instance.lastMessageTimestamp,
      'encrypted': instance.encrypted,
    };

MemberDto _$MemberDtoFromJson(Map<String, dynamic> json) => MemberDto(
      publicKey: json['encrypted'] as String,
      scopes: (json['scopes'] as List<dynamic>)
          .map((e) => $enumDecode(_$MemberScopeDtoEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$MemberDtoToJson(MemberDto instance) => <String, dynamic>{
      'encrypted': instance.publicKey,
      'scopes': instance.scopes.map((e) => _$MemberScopeDtoEnumMap[e]).toList(),
    };

const _$MemberScopeDtoEnumMap = {
  MemberScopeDto.admin: 'ADMIN',
  MemberScopeDto.write: 'WRITE',
};

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
      owner: json['owner'] as String,
      text: (json['text'] as List<dynamic>).map((e) => e as num).toList(),
      timestamp: json['timestamp'] as num,
    );

Map<String, dynamic> _$MessageDtoToJson(MessageDto instance) =>
    <String, dynamic>{
      'owner': instance.owner,
      'text': instance.text,
      'timestamp': instance.timestamp,
    };

PostMemberDto _$PostMemberDtoFromJson(Map<String, dynamic> json) =>
    PostMemberDto(
      publicKey: json['publicKey'] as String,
      scopes: (json['scopes'] as List<dynamic>)
          .map((e) => $enumDecode(_$MemberScopeDtoEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$PostMemberDtoToJson(PostMemberDto instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
      'scopes': instance.scopes.map((e) => _$MemberScopeDtoEnumMap[e]).toList(),
    };

SendMessageCommand _$SendMessageCommandFromJson(Map<String, dynamic> json) =>
    SendMessageCommand(
      text: (json['text'] as List<dynamic>).map((e) => e as num).toList(),
    );

Map<String, dynamic> _$SendMessageCommandToJson(SendMessageCommand instance) =>
    <String, dynamic>{
      'text': instance.text,
    };
