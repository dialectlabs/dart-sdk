import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/wallet/wallet.interface.dart';
import 'package:json_annotation/json_annotation.dart';

final Map<AddressTypeDto, AddressType> addressTypeDtoToAddressType = {
  AddressTypeDto.email: AddressType.email,
  AddressTypeDto.phoneNumber: AddressType.phoneNumber,
  AddressTypeDto.telegram: AddressType.telegram,
  AddressTypeDto.wallet: AddressType.wallet
};

final Map<AddressType, AddressTypeDto> addressTypeToAddressTypeDto = {
  AddressType.email: AddressTypeDto.email,
  AddressType.phoneNumber: AddressTypeDto.phoneNumber,
  AddressType.telegram: AddressTypeDto.telegram,
  AddressType.wallet: AddressTypeDto.wallet
};

AddressType toAddressType(AddressTypeDto type) {
  final addressType = addressTypeDtoToAddressType[type];
  if (addressType == null) {
    throw IllegalArgumentError(title: 'Unknown address type $type');
  }
  return addressType;
}

AddressTypeDto toAddressTypeDto(AddressType type) {
  final addressTypeDto = addressTypeToAddressTypeDto[type];
  if (addressTypeDto == null) {
    throw IllegalArgumentError(title: 'Unknown address type $type');
  }
  return addressTypeDto;
}

class Address {
  String id;
  AddressType type;
  bool verified;
  String value;
  Wallet wallet;
  Address(this.id, this.type, this.verified, this.value, this.wallet);
}

enum AddressType {
  @JsonValue(AddressTypeValues.email)
  email,
  @JsonValue(AddressTypeValues.phoneNumber)
  phoneNumber,
  @JsonValue(AddressTypeValues.telegram)
  telegram,
  @JsonValue(AddressTypeValues.wallet)
  wallet
}

class AddressTypeValues {
  static const String email = "EMAIL";
  static const String phoneNumber = "PHONE_NUMBER";
  static const String telegram = "TELEGRAM";
  static const String wallet = "WALLET";
}

class DappAddress {
  String id;
  bool enabled;
  String? channelId;
  Address address;

  DappAddress(this.id, this.enabled, this.channelId, this.address);
}
