// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dapp_client_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressDto _$AddressDtoFromJson(Map<String, dynamic> json) => AddressDto(
      json['id'] as String,
      $enumDecode(_$AddressTypeDtoEnumMap, json['type']),
      json['verified'] as bool,
      json['value'] as String,
      WalletDto.fromJson(json['wallet'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddressDtoToJson(AddressDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AddressTypeDtoEnumMap[instance.type],
      'verified': instance.verified,
      'value': instance.value,
      'wallet': instance.wallet.toJson(),
    };

const _$AddressTypeDtoEnumMap = {
  AddressTypeDto.email: 'EMAIL',
  AddressTypeDto.phoneNumber: 'PHONE_NUMBER',
  AddressTypeDto.telegram: 'TELEGRAM',
  AddressTypeDto.wallet: 'WALLET',
};

BroadcastDappMessageCommandDto _$BroadcastDappMessageCommandDtoFromJson(
        Map<String, dynamic> json) =>
    BroadcastDappMessageCommandDto(
      json['title'] as String,
      json['message'] as String,
    );

Map<String, dynamic> _$BroadcastDappMessageCommandDtoToJson(
        BroadcastDappMessageCommandDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'message': instance.message,
    };

CreateDappCommandDto _$CreateDappCommandDtoFromJson(
        Map<String, dynamic> json) =>
    CreateDappCommandDto(
      json['name'] as String,
      json['description'] as String?,
      json['publicKey'] as String,
    );

Map<String, dynamic> _$CreateDappCommandDtoToJson(
        CreateDappCommandDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'publicKey': instance.publicKey,
    };

CreateDappCommandDtoPartial _$CreateDappCommandDtoPartialFromJson(
        Map<String, dynamic> json) =>
    CreateDappCommandDtoPartial(
      json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CreateDappCommandDtoPartialToJson(
        CreateDappCommandDtoPartial instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

DappDto _$DappDtoFromJson(Map<String, dynamic> json) => DappDto(
      json['id'] as String,
      json['publicKey'] as String,
      json['name'] as String,
      json['verified'] as bool,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$DappDtoToJson(DappDto instance) => <String, dynamic>{
      'id': instance.id,
      'publicKey': instance.publicKey,
      'name': instance.name,
      'description': instance.description,
      'verified': instance.verified,
    };

FindDappQueryDto _$FindDappQueryDtoFromJson(Map<String, dynamic> json) =>
    FindDappQueryDto(
      json['verified'] as bool?,
    );

Map<String, dynamic> _$FindDappQueryDtoToJson(FindDappQueryDto instance) =>
    <String, dynamic>{
      'verified': instance.verified,
    };

MulticastDappMessageCommandDto _$MulticastDappMessageCommandDtoFromJson(
        Map<String, dynamic> json) =>
    MulticastDappMessageCommandDto(
      json['title'] as String,
      json['message'] as String,
      (json['recipientPublicKeys'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$MulticastDappMessageCommandDtoToJson(
        MulticastDappMessageCommandDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'message': instance.message,
      'recipientPublicKeys': instance.recipientPublicKeys,
    };

UnicastDappMessageCommandDto _$UnicastDappMessageCommandDtoFromJson(
        Map<String, dynamic> json) =>
    UnicastDappMessageCommandDto(
      json['title'] as String,
      json['message'] as String,
      json['recipientPublicKey'] as String,
    );

Map<String, dynamic> _$UnicastDappMessageCommandDtoToJson(
        UnicastDappMessageCommandDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'message': instance.message,
      'recipientPublicKey': instance.recipientPublicKey,
    };

WalletDto _$WalletDtoFromJson(Map<String, dynamic> json) => WalletDto(
      json['id'] as String,
      json['publicKey'] as String,
    );

Map<String, dynamic> _$WalletDtoToJson(WalletDto instance) => <String, dynamic>{
      'id': instance.id,
      'publicKey': instance.publicKey,
    };
