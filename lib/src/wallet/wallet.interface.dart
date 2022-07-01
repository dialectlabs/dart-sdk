import 'package:dialect_sdk/src/address/addresses.interface.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_dapp_addresses/data_service_wallet_dapp_addresses_dtos.dart';
import 'package:solana/solana.dart';

class CreateAddressCommand {
  final String value;
  final AddressType type;
  CreateAddressCommand(this.value, this.type);
}

class CreateDappAddressCommand {
  final Ed25519HDPublicKey dappPublicKey;
  final String addressId;
  final bool enabled;
  CreateDappAddressCommand(this.dappPublicKey, this.addressId, this.enabled);
}

class DappMessage {
  String text;
  DateTime timestamp;
  Ed25519HDPublicKey author;
  DappMessage(this.text, this.timestamp, this.author);
}

class DeleteAddressCommand {
  final String addressId;
  DeleteAddressCommand(this.addressId);
}

class DeleteDappAddressCommand {
  final String dappAddressId;
  DeleteDappAddressCommand(this.dappAddressId);
}

class FindDappAddressQuery {
  final String dappAddressId;
  FindDappAddressQuery(this.dappAddressId);
}

class FindDappMessageQuery {
  final int? skip;
  final int? take;
  final bool dappVerified;
  FindDappMessageQuery(this.skip, this.take, this.dappVerified);
}

class PartialUpdateAddressCommand {
  final String addressId;
  final AddressType type;
  PartialUpdateAddressCommand(this.addressId, this.type);
}

class PartialUpdateDappAddressCommand {
  final String dappAddressId;
  final bool? enabled;
  PartialUpdateDappAddressCommand(this.dappAddressId, this.enabled);
}

class ResendVerificationCodeCommand {
  final String addressId;
  ResendVerificationCodeCommand(this.addressId);
}

class VerifyAddressCommand {
  final String addressId;
  final String code;
  VerifyAddressCommand(this.addressId, this.code);
}

class Wallet {
  final Ed25519HDPublicKey publicKey;
  Wallet(this.publicKey);
}

abstract class WalletAddresses {
  Future<Address> create(CreateAddressCommand command);
  Future delete(DeleteAddressCommand command);
  Future<Address> update(PartialUpdateAddressCommand command);
}

abstract class WalletDappAddresses {
  Future<DappAddress> create(CreateDappAddressCommand command);
  Future delete(DeleteDappAddressCommand command);
  Future<DappMessage> find(FindDappAddressQuery query);
  Future<List<DappMessage>> findAll(FindDappAddressesQuery query);
  Future<DappAddress> update(PartialUpdateDappAddressCommand command);
}

abstract class WalletDappMessages {
  Future<List<DappMessage>> findAll(FindDappMessageQuery query);
}
