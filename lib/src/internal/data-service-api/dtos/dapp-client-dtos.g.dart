// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dapp-client-dtos.dart';

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
  AddressTypeDto.sms: 'SMS',
  AddressTypeDto.telegram: 'TELEGRAM',
  AddressTypeDto.wallet: 'WALLET',
};

CreateDappCommandDto _$CreateDappCommandDtoFromJson(
        Map<String, dynamic> json) =>
    CreateDappCommandDto(
      json['publicKey'] as String,
    );

Map<String, dynamic> _$CreateDappCommandDtoToJson(
        CreateDappCommandDto instance) =>
    <String, dynamic>{
      'publicKey': instance.publicKey,
    };

DappAddressDto _$DappAddressDtoFromJson(Map<String, dynamic> json) =>
    DappAddressDto(
      json['id'] as String,
      json['enabled'] as bool,
      json['telegramChatId'] as String,
      AddressDto.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DappAddressDtoToJson(DappAddressDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'enabled': instance.enabled,
      'telegramChatId': instance.telegramChatId,
      'address': instance.address.toJson(),
    };

DappDto _$DappDtoFromJson(Map<String, dynamic> json) => DappDto(
      json['id'] as String,
      json['publicKey'] as String,
    );

Map<String, dynamic> _$DappDtoToJson(DappDto instance) => <String, dynamic>{
      'id': instance.id,
      'publicKey': instance.publicKey,
    };

WalletDto _$WalletDtoFromJson(Map<String, dynamic> json) => WalletDto(
      json['id'] as String,
      json['publicKey'] as String,
    );

Map<String, dynamic> _$WalletDtoToJson(WalletDto instance) => <String, dynamic>{
      'id': instance.id,
      'publicKey': instance.publicKey,
    };
