import 'package:dialect_sdk/src/core/constants/constants.dart';
import 'package:dialect_sdk/src/web3/api/external/cardinal-twitter/cardinal-twitter.dart';
import 'package:dialect_sdk/src/web3/api/external/cardinal-twitter/constants.dart';
import 'package:dialect_sdk/src/web3/programs.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  group('Cardinal twitter service', () {
    final baseUrl = programs.mainnet.clusterAddress;
    print("testing with URL: $baseUrl");
    final client = RpcClient(baseUrl);

    test('test get name fail', () async {
      final displayName =
          await tryGetName(client, NAMESPACES_PROGRAM_ID, DEFAULT_PUBKEY);
      expect(displayName, equals(null));
    });

    test('test get pubkey from name success', () async {
      final handle = "saydialect";
      final pubKey = Ed25519HDPublicKey.fromBase58(
          "D1ALECTfeCZt9bAbPWtJk7ntv24vDYGPmyS7swp7DY5h");

      final key = await getNameEntry(client, twitterNamespace, handle);
      expect(key.parsed.data, equals(pubKey));
    });

    test('test get name from pubkey success', () async {
      final displayName = await tryGetName(
          client,
          NAMESPACES_PROGRAM_ID,
          Ed25519HDPublicKey.fromBase58(
              "7sF56xvsiCQDLAHEHtrYCVjPtQGwTjVjPYLomEFJPsGV"));
      expect(displayName, equals("@proofofkevin"));
    });
  });
}
