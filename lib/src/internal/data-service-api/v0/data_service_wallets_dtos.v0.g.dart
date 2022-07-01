// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_service_wallets_dtos.v0.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAddressCommandV0 _$CreateAddressCommandV0FromJson(
        Map<String, dynamic> json) =>
    CreateAddressCommandV0(
      type: json['type'] as String,
      value: json['value'] as String,
      enabled: json['enabled'] as bool,
    );

Map<String, dynamic> _$CreateAddressCommandV0ToJson(
        CreateAddressCommandV0 instance) =>
    <String, dynamic>{
      'type': instance.type,
      'value': instance.value,
      'enabled': instance.enabled,
    };

DappAddressDtoV0 _$DappAddressDtoV0FromJson(Map<String, dynamic> json) =>
    DappAddressDtoV0(
      id: json['id'] as String,
      type: $enumDecode(_$AddressTypeV0EnumMap, json['type']),
      verified: json['verified'] as bool,
      addressId: json['addressId'] as String,
      dapp: json['dapp'] as String,
      enabled: json['enabled'] as bool,
      value: json['value'] as String?,
    );

Map<String, dynamic> _$DappAddressDtoV0ToJson(DappAddressDtoV0 instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AddressTypeV0EnumMap[instance.type],
      'verified': instance.verified,
      'addressId': instance.addressId,
      'dapp': instance.dapp,
      'enabled': instance.enabled,
      'value': instance.value,
    };

const _$AddressTypeV0EnumMap = {
  AddressTypeV0.email: 'email',
  AddressTypeV0.sms: 'sms',
  AddressTypeV0.telegram: 'telegram',
  AddressTypeV0.wallet: 'wallet',
};

DeleteAddressCommandV0 _$DeleteAddressCommandV0FromJson(
        Map<String, dynamic> json) =>
    DeleteAddressCommandV0(
      id: json['id'] as String,
    );

Map<String, dynamic> _$DeleteAddressCommandV0ToJson(
        DeleteAddressCommandV0 instance) =>
    <String, dynamic>{
      'id': instance.id,
    };
