// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_service_wallet_dapp_addresses_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateDappAddressCommandDto _$CreateDappAddressCommandDtoFromJson(
        Map<String, dynamic> json) =>
    CreateDappAddressCommandDto(
      json['dappPublicKey'] as String,
      json['addressId'] as String,
      json['enabled'] as bool,
    );

Map<String, dynamic> _$CreateDappAddressCommandDtoToJson(
        CreateDappAddressCommandDto instance) =>
    <String, dynamic>{
      'dappPublicKey': instance.dappPublicKey,
      'addressId': instance.addressId,
      'enabled': instance.enabled,
    };

DappAddressDto _$DappAddressDtoFromJson(Map<String, dynamic> json) =>
    DappAddressDto(
      json['id'] as String,
      json['enabled'] as bool,
      json['channelId'] as String?,
      AddressDto.fromJson(json['address'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DappAddressDtoToJson(DappAddressDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'enabled': instance.enabled,
      'channelId': instance.channelId,
      'address': instance.address.toJson(),
    };

FindDappAddressesQuery _$FindDappAddressesQueryFromJson(
        Map<String, dynamic> json) =>
    FindDappAddressesQuery(
      addressIds: (json['addressIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dappPublicKey: json['dappPublicKey'] as String?,
    );

Map<String, dynamic> _$FindDappAddressesQueryToJson(
        FindDappAddressesQuery instance) =>
    <String, dynamic>{
      'addressIds': instance.addressIds,
      'dappPublicKey': instance.dappPublicKey,
    };

PartialUpdateDappAddressCommandDto _$PartialUpdateDappAddressCommandDtoFromJson(
        Map<String, dynamic> json) =>
    PartialUpdateDappAddressCommandDto(
      json['enabled'] as bool,
    );

Map<String, dynamic> _$PartialUpdateDappAddressCommandDtoToJson(
        PartialUpdateDappAddressCommandDto instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
    };
