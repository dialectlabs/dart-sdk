import 'package:async/async.dart';
import "package:collection/collection.dart";
import 'package:dialect_sdk/src/address/addresses.interface.dart';
import 'package:dialect_sdk/src/dapp/dapp.interface.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/wallet/wallet.interface.dart' as w;
import 'package:solana/solana.dart';

class DappAddressesFacade implements DappAddresses {
  List<DappAddresses> dappAddressesBackends;

  DappAddressesFacade(this.dappAddressesBackends) {
    if (dappAddressesBackends.isEmpty) {
      throw IllegalArgumentError(
          title: "Expected to have at least one dapp addresses backend.");
    }
  }

  @override
  Future<List<DappAddress>> findAll() async {
    final allSettled = await Future.wait(
        dappAddressesBackends.map((e) => Result.capture(e.findAll())));
    final rejected = allSettled.where((element) => element.isError);
    if (rejected.isNotEmpty) {
      print(
          "Error finding dapp addresses: ${rejected.map((e) => e.asError?.error)}");
    }
    final allDappAddresses = allSettled
        .where((element) => element.isValue)
        .map((e) => e.asValue!.value)
        .expand((element) => element);
    final walletAddresses = allDappAddresses
        .where((element) => element.address.type == AddressType.wallet);
    final deduplicatedWalletAddresses =
        DappAddressesFacade._dedupleWalletAddresses(walletAddresses.toList());
    final nonWalletAddresses = allDappAddresses
        .where((element) => element.address.type != AddressType.wallet);
    return [...deduplicatedWalletAddresses, ...nonWalletAddresses];
  }

  static List<DappAddress> _dedupleWalletAddresses(
      List<DappAddress> walletAddresses) {
    final walletPublicKeyToWalletAddresses = groupBy(walletAddresses,
        (DappAddress e) => e.address.wallet.publicKey.toBase58());
    return walletPublicKeyToWalletAddresses.entries
        .map((e) => e.value.reduce((prev, curr) => DappAddress(
            prev.id,
            prev.enabled && curr.enabled,
            null,
            Address(prev.id, prev.address.type, true, e.key,
                w.Wallet(Ed25519HDPublicKey.fromBase58(e.key))))))
        .toList();
  }
}
