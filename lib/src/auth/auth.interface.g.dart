// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.interface.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Token _$TokenFromJson(Map<String, dynamic> json) => Token(
      rawValue: json['rawValue'] as String,
      header: TokenHeader.fromJson(json['header'] as Map<String, dynamic>),
      body: TokenBody.fromJson(json['body'] as Map<String, dynamic>),
      signature:
          const Uint8ListConverter().fromJson(json['signature'] as List<int>),
      base64Header: json['base64Header'] as String,
      base64Body: json['base64Body'] as String,
      base64Signature: json['base64Signature'] as String,
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'rawValue': instance.rawValue,
      'header': instance.header.toJson(),
      'body': instance.body.toJson(),
      'signature': const Uint8ListConverter().toJson(instance.signature),
      'base64Header': instance.base64Header,
      'base64Body': instance.base64Body,
      'base64Signature': instance.base64Signature,
    };

TokenBody _$TokenBodyFromJson(Map<String, dynamic> json) => TokenBody(
      sub: json['sub'] as String,
      iat: json['iat'] as int?,
      exp: json['exp'] as int,
    );

Map<String, dynamic> _$TokenBodyToJson(TokenBody instance) => <String, dynamic>{
      'sub': instance.sub,
      'iat': instance.iat,
      'exp': instance.exp,
    };

TokenHeader _$TokenHeaderFromJson(Map<String, dynamic> json) => TokenHeader(
      alg: json['alg'] as String?,
      typ: json['typ'] as String?,
    );

Map<String, dynamic> _$TokenHeaderToJson(TokenHeader instance) =>
    <String, dynamic>{
      'alg': instance.alg,
      'typ': instance.typ,
    };
