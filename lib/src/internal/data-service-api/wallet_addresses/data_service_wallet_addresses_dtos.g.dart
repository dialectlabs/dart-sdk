// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_service_wallet_addresses_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAddressCommandDto _$CreateAddressCommandDtoFromJson(
        Map<String, dynamic> json) =>
    CreateAddressCommandDto(
      json['value'] as String,
      $enumDecode(_$AddressTypeDtoEnumMap, json['type']),
    );

Map<String, dynamic> _$CreateAddressCommandDtoToJson(
        CreateAddressCommandDto instance) =>
    <String, dynamic>{
      'value': instance.value,
      'type': _$AddressTypeDtoEnumMap[instance.type],
    };

const _$AddressTypeDtoEnumMap = {
  AddressTypeDto.email: 'EMAIL',
  AddressTypeDto.phoneNumber: 'PHONE_NUMBER',
  AddressTypeDto.telegram: 'TELEGRAM',
  AddressTypeDto.wallet: 'WALLET',
};

PatchAddressCommandDto _$PatchAddressCommandDtoFromJson(
        Map<String, dynamic> json) =>
    PatchAddressCommandDto(
      json['value'] as String?,
    );

Map<String, dynamic> _$PatchAddressCommandDtoToJson(
        PatchAddressCommandDto instance) =>
    <String, dynamic>{
      'value': instance.value,
    };

VerifyAddressCommandDto _$VerifyAddressCommandDtoFromJson(
        Map<String, dynamic> json) =>
    VerifyAddressCommandDto(
      json['code'] as String,
    );

Map<String, dynamic> _$VerifyAddressCommandDtoToJson(
        VerifyAddressCommandDto instance) =>
    <String, dynamic>{
      'code': instance.code,
    };
