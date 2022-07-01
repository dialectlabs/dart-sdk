import 'package:dialect_sdk/src/dapp/dapp.interface.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/data_service_dapps_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_errors.dart';

class DataServiceDappMessages implements DappMessages {
  final DataServiceDappsApi _api;

  DataServiceDappMessages(this._api);

  Future broadcast(BroadcastDappMessageCommand command) async {
    return withErrorParsing(_api.broadcast(
        BroadcastDappMessageCommandDto(command.title, command.message)));
  }

  Future multicast(MulticastDappMessageCommand command) async {
    return withErrorParsing(_api.multicast(MulticastDappMessageCommandDto(
        command.title,
        command.message,
        command.recipients.map((e) => e.toBase58()).toList())));
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
    return withErrorParsing(_api.unicast(UnicastDappMessageCommandDto(
        command.title, command.message, command.recipient.toBase58())));
  }
}
