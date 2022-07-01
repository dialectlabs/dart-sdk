import 'dart:convert';

import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_service_wallet_dapp_addresses_dtos.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateDappAddressCommandDto {
  @JsonKey(name: "dappPublicKey")
  final String dappPublicKey;
  @JsonKey(name: "addressId")
  final String addressId;
  @JsonKey(name: "enabled")
  final bool enabled;

  CreateDappAddressCommandDto(this.dappPublicKey, this.addressId, this.enabled);

  factory CreateDappAddressCommandDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDappAddressCommandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDappAddressCommandDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DappAddressDto {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "enabled")
  final bool enabled;
  @JsonKey(name: "channelId")
  final String? channelId;
  @JsonKey(name: "address")
  final AddressDto address;

  DappAddressDto(this.id, this.enabled, this.channelId, this.address);

  factory DappAddressDto.fromJson(Map<String, dynamic> json) =>
      _$DappAddressDtoFromJson(json);

  @override
  int get hashCode => JsonEncoder().convert(toJson()).hashCode;

  @override
  bool operator ==(covariant DappAddressDto other) {
    return id == other.id &&
        enabled == other.enabled &&
        channelId == other.channelId &&
        address == other.address;
  }

  Map<String, dynamic> toJson() => _$DappAddressDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FindDappAddressesQuery {
  @JsonKey(name: "addressIds")
  final List<String>? addressIds;
  @JsonKey(name: "dappPublicKey")
  final String? dappPublicKey;
  FindDappAddressesQuery({this.addressIds, this.dappPublicKey});

  factory FindDappAddressesQuery.fromJson(Map<String, dynamic> json) =>
      _$FindDappAddressesQueryFromJson(json);

  Map<String, dynamic> toJson() => _$FindDappAddressesQueryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PartialUpdateDappAddressCommandDto {
  @JsonKey(name: "enabled")
  final bool enabled;

  PartialUpdateDappAddressCommandDto(this.enabled);

  factory PartialUpdateDappAddressCommandDto.fromJson(
          Map<String, dynamic> json) =>
      _$PartialUpdateDappAddressCommandDtoFromJson(json);

  Map<String, dynamic> toJson() =>
      _$PartialUpdateDappAddressCommandDtoToJson(this);
}
