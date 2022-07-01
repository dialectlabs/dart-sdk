import 'package:dialect_sdk/src/address/addresses.interface.dart';
import 'package:solana/solana.dart';

class BroadcastDappMessageCommand {
  final String title;
  final String message;
  BroadcastDappMessageCommand(this.title, this.message);
}

class CreateDappCommand {
  String name;
  String? description;
  CreateDappCommand(this.name, this.description);
}

class Dapp extends DappBase {
  DappAddresses dappAddresses;
  Dapp(Ed25519HDPublicKey publicKey, String name, String? description,
      bool verified, this.dappAddresses)
      : super(publicKey, name, description, verified);
}

abstract class DappAddresses {
  Future<List<DappAddress>> findAll();
}

class DappBase {
  Ed25519HDPublicKey publicKey;
  String name;
  String? description;
  bool verified;
  DappBase(this.publicKey, this.name, this.description, this.verified);
}

abstract class DappMessages {
  Future send(SendDappMessageCommand command);
}

abstract class Dapps {
  Future<Dapp> create(CreateDappCommand command);
  Future<Dapp?> find();
  Future<List<DappBase>> findAll(FindDappQuery? query);
}

class FindDappQuery {
  bool? verified;
  FindDappQuery(this.verified);
}

class MulticastDappMessageCommand {
  final String title;
  final String message;
  final List<Ed25519HDPublicKey> recipients;
  MulticastDappMessageCommand(this.title, this.message, this.recipients);
}

class SendDappMessageCommand {
  final BroadcastDappMessageCommand? broadcastCommand;
  final MulticastDappMessageCommand? multicastCommand;
  final UnicastDappMessageCommand? unicastCommand;

  SendDappMessageCommand.fromBroadcast(this.broadcastCommand)
      : multicastCommand = null,
        unicastCommand = null;
  SendDappMessageCommand.fromMulticast(this.multicastCommand)
      : broadcastCommand = null,
        unicastCommand = null;
  SendDappMessageCommand.fromUnicast(this.unicastCommand)
      : multicastCommand = null,
        broadcastCommand = null;

  bool get isBroadcast => broadcastCommand != null;
  bool get isMulticast => multicastCommand != null;
  bool get isUnicast => unicastCommand != null;
}

class UnicastDappMessageCommand {
  final String title;
  final String message;
  final Ed25519HDPublicKey recipient;
  UnicastDappMessageCommand(this.title, this.message, this.recipient);
}
