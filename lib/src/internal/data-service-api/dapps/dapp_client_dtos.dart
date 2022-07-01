import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'dapp_client_dtos.g.dart';

@JsonSerializable(explicitToJson: true)
class AddressDto {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "type")
  final AddressTypeDto type;
  @JsonKey(name: "verified")
  final bool verified;
  @JsonKey(name: "value")
  final String value;
  @JsonKey(name: "wallet")
  final WalletDto wallet;

  AddressDto(this.id, this.type, this.verified, this.value, this.wallet);

  factory AddressDto.fromJson(Map<String, dynamic> json) =>
      _$AddressDtoFromJson(json);

  @override
  int get hashCode => JsonEncoder().convert(toJson()).hashCode;

  @override
  bool operator ==(covariant AddressDto other) {
    return id == other.id &&
        type == other.type &&
        verified == other.verified &&
        wallet == other.wallet;
  }

  Map<String, dynamic> toJson() => _$AddressDtoToJson(this);
}

enum AddressTypeDto {
  @JsonValue(AddressTypeDtoValues.email)
  email,
  @JsonValue(AddressTypeDtoValues.phoneNumber)
  phoneNumber,
  @JsonValue(AddressTypeDtoValues.telegram)
  telegram,
  @JsonValue(AddressTypeDtoValues.wallet)
  wallet
}

class AddressTypeDtoValues {
  static const String email = "EMAIL";
  static const String phoneNumber = "PHONE_NUMBER";
  static const String telegram = "TELEGRAM";
  static const String wallet = "WALLET";
}

@JsonSerializable(explicitToJson: true)
class BroadcastDappMessageCommandDto {
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "message")
  String message;
  BroadcastDappMessageCommandDto(this.title, this.message);

  factory BroadcastDappMessageCommandDto.fromJson(Map<String, dynamic> json) =>
      _$BroadcastDappMessageCommandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BroadcastDappMessageCommandDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateDappCommandDto extends CreateDappCommandDtoPartial {
  @JsonKey(name: "publicKey")
  final String publicKey;

  CreateDappCommandDto(String name, String? description, this.publicKey)
      : super(name, description: description);

  factory CreateDappCommandDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDappCommandDtoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CreateDappCommandDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CreateDappCommandDtoPartial {
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "description")
  final String? description;

  CreateDappCommandDtoPartial(this.name, {this.description});

  factory CreateDappCommandDtoPartial.fromJson(Map<String, dynamic> json) =>
      _$CreateDappCommandDtoPartialFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDappCommandDtoPartialToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DappDto {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "publicKey")
  final String publicKey;
  @JsonKey(name: "name")
  final String name;
  @JsonKey(name: "description")
  final String? description;
  @JsonKey(name: "verified")
  final bool verified;

  DappDto(this.id, this.publicKey, this.name, this.verified,
      {this.description});

  factory DappDto.fromJson(Map<String, dynamic> json) =>
      _$DappDtoFromJson(json);

  @override
  int get hashCode => JsonEncoder().convert(toJson()).hashCode;

  @override
  bool operator ==(covariant DappDto other) {
    return publicKey == other.publicKey &&
        id == other.id &&
        name == other.name &&
        description == other.description &&
        verified == other.verified;
  }

  Map<String, dynamic> toJson() => _$DappDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FindDappQueryDto {
  @JsonKey(name: "verified")
  bool? verified;
  FindDappQueryDto(this.verified);

  factory FindDappQueryDto.fromJson(Map<String, dynamic> json) =>
      _$FindDappQueryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FindDappQueryDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class MulticastDappMessageCommandDto {
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "message")
  String message;
  @JsonKey(name: "recipientPublicKeys")
  List<String> recipientPublicKeys;
  MulticastDappMessageCommandDto(
      this.title, this.message, this.recipientPublicKeys);

  factory MulticastDappMessageCommandDto.fromJson(Map<String, dynamic> json) =>
      _$MulticastDappMessageCommandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MulticastDappMessageCommandDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class UnicastDappMessageCommandDto {
  @JsonKey(name: "title")
  String title;
  @JsonKey(name: "message")
  String message;
  @JsonKey(name: "recipientPublicKey")
  String recipientPublicKey;
  UnicastDappMessageCommandDto(
      this.title, this.message, this.recipientPublicKey);

  factory UnicastDappMessageCommandDto.fromJson(Map<String, dynamic> json) =>
      _$UnicastDappMessageCommandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UnicastDappMessageCommandDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WalletDto {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "publicKey")
  final String publicKey;

  WalletDto(this.id, this.publicKey);

  factory WalletDto.fromJson(Map<String, dynamic> json) =>
      _$WalletDtoFromJson(json);

  @override
  int get hashCode => JsonEncoder().convert(toJson()).hashCode;

  @override
  bool operator ==(covariant WalletDto other) {
    return id == other.id && publicKey == other.publicKey;
  }

  Map<String, dynamic> toJson() => _$WalletDtoToJson(this);
}
