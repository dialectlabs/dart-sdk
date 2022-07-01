import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'data_service_wallets_dtos.v0.g.dart';

enum AddressTypeV0 {
  @JsonValue(AddressTypeValuesV0.email)
  email,
  @JsonValue(AddressTypeValuesV0.sms)
  sms,
  @JsonValue(AddressTypeValuesV0.telegram)
  telegram,
  @JsonValue(AddressTypeValuesV0.wallet)
  wallet
}

class AddressTypeValuesV0 {
  static const String email = "email";
  static const String sms = "sms";
  static const String telegram = "telegram";
  static const String wallet = "wallet";
}

@JsonSerializable(explicitToJson: true)
class CreateAddressCommandV0 {
  @JsonKey(name: "type")
  final String type;
  @JsonKey(name: "value")
  final String value;
  @JsonKey(name: "enabled")
  final bool enabled;
  CreateAddressCommandV0(
      {required this.type, required this.value, required this.enabled});

  factory CreateAddressCommandV0.fromJson(Map<String, dynamic> json) =>
      _$CreateAddressCommandV0FromJson(json);
  Map<String, dynamic> toJson() => _$CreateAddressCommandV0ToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DappAddressDtoV0 {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "type")
  final AddressTypeV0 type;
  @JsonKey(name: "verified")
  final bool verified;
  @JsonKey(name: "addressId")
  final String addressId;
  @JsonKey(name: "dapp")
  final String dapp;
  @JsonKey(name: "enabled")
  final bool enabled;
  @JsonKey(name: "value")
  final String? value;

  DappAddressDtoV0(
      {required this.id,
      required this.type,
      required this.verified,
      required this.addressId,
      required this.dapp,
      required this.enabled,
      required this.value});

  factory DappAddressDtoV0.fromJson(Map<String, dynamic> json) =>
      _$DappAddressDtoV0FromJson(json);

  @override
  int get hashCode => JsonEncoder().convert(toJson()).hashCode;

  @override
  bool operator ==(covariant DappAddressDtoV0 other) {
    return id == other.id &&
        type == other.type &&
        verified == other.verified &&
        addressId == other.addressId &&
        dapp == other.dapp &&
        enabled == other.enabled &&
        value == other.value;
  }

  Map<String, dynamic> toJson() => _$DappAddressDtoV0ToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DeleteAddressCommandV0 {
  @JsonKey(name: "id")
  final String id;

  DeleteAddressCommandV0({required this.id});

  factory DeleteAddressCommandV0.fromJson(Map<String, dynamic> json) =>
      _$DeleteAddressCommandV0FromJson(json);
  Map<String, dynamic> toJson() => _$DeleteAddressCommandV0ToJson(this);
}
