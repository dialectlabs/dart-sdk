import 'package:async/async.dart';
import 'package:dialect_sdk/src/address/addresses.interface.dart';
import 'package:dialect_sdk/src/dapp/dapp.interface.dart';
import 'package:dialect_sdk/src/internal/dapp/solana_dapp_addresses.dart';
import 'package:dialect_sdk/src/internal/messaging/solana_messaging.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:solana/solana.dart';

class SolanaDappMessages implements DappMessages {
  final SolanaMessaging _messaging;
  final SolanaDappAddresses _addresses;

  SolanaDappMessages(this._messaging, this._addresses);

  Future broadcast(BroadcastDappMessageCommand command) async {
    final dappAddresses = await _addresses.findAll();
    return multicast(MulticastDappMessageCommand(
        command.title,
        command.message,
        dappAddresses
            .where((element) => element.address.type == AddressType.wallet)
            .map((e) => Ed25519HDPublicKey.fromBase58(e.address.value))
            .toList()));
  }

  Future multicast(MulticastDappMessageCommand command) async {
    final allSettled = await Future.wait(command.recipients.map((e) =>
        Result.capture(unicast(
            UnicastDappMessageCommand(command.title, command.message, e)))));
    final rejected = allSettled.where((element) => element.isError);
    if (rejected.isNotEmpty) {
      print(
          "Error sending solana dapp messages: ${rejected.map((e) => e.asError!.error)}");
    }
  }

  @override
  Future send(SendDappMessageCommand command) {
    if (command.isBroadcast) {
      return broadcast(command.broadcastCommand!);
    }
    if (command.isMulticast) {
      return multicast(command.multicastCommand!);
    }
    return unicast(command.unicastCommand!);
  }

  Future unicast(UnicastDappMessageCommand command) async {
    final thread = await _messaging
        .find(FindThreadByOtherMemberQuery(otherMembers: [command.recipient]));
    if (thread != null) {
      return thread.send(SendMessageCommand(text: command.message));
    }
  }
}
