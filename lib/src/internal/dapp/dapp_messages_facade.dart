import 'package:async/async.dart';
import 'package:dialect_sdk/src/dapp/dapp.interface.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';

class DappMessagesFacade implements DappMessages {
  final List<DappMessages> dappMessageBackends;

  DappMessagesFacade(this.dappMessageBackends) {
    if (dappMessageBackends.isEmpty) {
      throw IllegalArgumentError(
          title: 'Expected to have at least one dapp message backend.');
    }
  }

  @override
  Future send(SendDappMessageCommand command) async {
    final allSettled = await Future.wait(
        dappMessageBackends.map((e) => Result.capture(e.send(command))));
    final rejected = allSettled.where((element) => element.isError);
    if (rejected.isNotEmpty) {
      print(
          "Error sending dapp messages: ${rejected.map((e) => e.asError?.error)}");
    }
  }
}
