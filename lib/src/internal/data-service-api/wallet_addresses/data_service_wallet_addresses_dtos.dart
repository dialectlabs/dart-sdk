import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_service_wallet_addresses_dtos.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateAddressCommandDto {
  @JsonKey(name: "value")
  final String value;
  @JsonKey(name: "type")
  final AddressTypeDto type;

  CreateAddressCommandDto(this.value, this.type);

  factory CreateAddressCommandDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAddressCommandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAddressCommandDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PatchAddressCommandDto {
  @JsonKey(name: "value")
  final String? value;

  PatchAddressCommandDto(this.value);

  factory PatchAddressCommandDto.fromJson(Map<String, dynamic> json) =>
      _$PatchAddressCommandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PatchAddressCommandDtoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class VerifyAddressCommandDto {
  @JsonKey(name: "code")
  final String code;

  VerifyAddressCommandDto(this.code);

  factory VerifyAddressCommandDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyAddressCommandDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyAddressCommandDtoToJson(this);
}
