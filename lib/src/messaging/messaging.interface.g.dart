// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging.interface.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateThreadCommand _$CreateThreadCommandFromJson(Map<String, dynamic> json) =>
    CreateThreadCommand(
      me: ThreadMemberPartial.fromJson(json['me'] as Map<String, dynamic>),
      otherMembers: (json['otherMembers'] as List<dynamic>)
          .map((e) => ThreadMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      encrypted: json['encrypted'] as bool,
      backend: $enumDecodeNullable(_$BackendEnumMap, json['backend']),
    );

Map<String, dynamic> _$CreateThreadCommandToJson(
        CreateThreadCommand instance) =>
    <String, dynamic>{
      'me': instance.me.toJson(),
      'otherMembers': instance.otherMembers.map((e) => e.toJson()).toList(),
      'encrypted': instance.encrypted,
      'backend': _$BackendEnumMap[instance.backend],
    };

const _$BackendEnumMap = {
  Backend.solana: 'SOLANA',
  Backend.dialectCloud: 'DIALECT_CLOUD',
};

SendMessageCommand _$SendMessageCommandFromJson(Map<String, dynamic> json) =>
    SendMessageCommand(
      text: json['text'] as String,
    );

Map<String, dynamic> _$SendMessageCommandToJson(SendMessageCommand instance) =>
    <String, dynamic>{
      'text': instance.text,
    };

ThreadMember _$ThreadMemberFromJson(Map<String, dynamic> json) => ThreadMember(
      publicKey: const Ed25519PublicKeyConverter()
          .fromJson(json['publicKey'] as String),
      scopes: (json['scopes'] as List<dynamic>)
          .map((e) => $enumDecode(_$ThreadMemberScopeEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$ThreadMemberToJson(ThreadMember instance) =>
    <String, dynamic>{
      'scopes':
          instance.scopes.map((e) => _$ThreadMemberScopeEnumMap[e]).toList(),
      'publicKey': const Ed25519PublicKeyConverter().toJson(instance.publicKey),
    };

const _$ThreadMemberScopeEnumMap = {
  ThreadMemberScope.admin: 'ADMIN',
  ThreadMemberScope.write: 'WRITE',
};

ThreadMemberPartial _$ThreadMemberPartialFromJson(Map<String, dynamic> json) =>
    ThreadMemberPartial(
      scopes: (json['scopes'] as List<dynamic>)
          .map((e) => $enumDecode(_$ThreadMemberScopeEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$ThreadMemberPartialToJson(
        ThreadMemberPartial instance) =>
    <String, dynamic>{
      'scopes':
          instance.scopes.map((e) => _$ThreadMemberScopeEnumMap[e]).toList(),
    };
