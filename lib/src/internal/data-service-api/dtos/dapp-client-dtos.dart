import 'package:json_annotation/json_annotation.dart';

part 'dapp-client-dtos.g.dart';

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

  Map<String, dynamic> toJson() => _$AddressDtoToJson(this);
}

enum AddressTypeDto {
  @JsonValue(AddressTypeDtoValues.email)
  email,
  @JsonValue(AddressTypeDtoValues.sms)
  sms,
  @JsonValue(AddressTypeDtoValues.telegram)
  telegram,
  @JsonValue(AddressTypeDtoValues.wallet)
  wallet
}

class AddressTypeDtoValues {
  static const String email = "EMAIL";
  static const String sms = "SMS";
  static const String telegram = "TELEGRAM";
  static const String wallet = "WALLET";
}

@JsonSerializable(explicitToJson: true)
class CreateDappCommandDto {
  @JsonKey(name: "publicKey")
  final String publicKey;

  CreateDappCommandDto(this.publicKey);

  factory CreateDappCommandDto.fromJson(Map<String, dynamic> json) =>
      _$CreateDappCommandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDappCommandDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DappAddressDto {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "enabled")
  final bool enabled;
  @JsonKey(name: "telegramChatId")
  final String telegramChatId;
  @JsonKey(name: "address")
  final AddressDto address;

  DappAddressDto(this.id, this.enabled, this.telegramChatId, this.address);

  factory DappAddressDto.fromJson(Map<String, dynamic> json) =>
      _$DappAddressDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DappAddressDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DappDto {
  @JsonKey(name: "id")
  final String id;
  @JsonKey(name: "publicKey")
  final String publicKey;

  DappDto(this.id, this.publicKey);

  factory DappDto.fromJson(Map<String, dynamic> json) =>
      _$DappDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DappDtoToJson(this);
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

  Map<String, dynamic> toJson() => _$WalletDtoToJson(this);
}
