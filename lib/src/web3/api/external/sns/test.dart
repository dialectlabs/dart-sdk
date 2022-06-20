import 'package:dialect_sdk/src/web3/api/external/sns/sns.dart';
import 'package:dialect_sdk/src/web3/programs.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  group('Solana name service', () {
    final baseUrl = programs.mainnet.clusterAddress;
    print("testing with URL: $baseUrl");
    final client = RpcClient(baseUrl);

    test('Find owned accounts succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");
      var accts = await findOwnedNameAccountsForUser(client, pubKey);
      expect(accts.length, equals(1));
    });

    test('Reverse lookup succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");
      final name = await fetchSolanaNameServiceName(client, pubKey.toBase58());
      expect(name, equals("dialect"));
    });

    test('Find favorite domain name succeess', () async {
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "7sF56xvsiCQDLAHEHtrYCVjPtQGwTjVjPYLomEFJPsGV");
      final name = await findFavoriteDomainName(client, pubKey);
      expect(name, equals("kdingens"));
    });
  });
}
