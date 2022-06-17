import 'package:dialect_sdk/src/core/constants/constants.dart';
import 'package:dialect_sdk/src/web3/api/cardinal-twitter/cardinal-twitter.dart';
import 'package:dialect_sdk/src/web3/api/cardinal-twitter/constants.dart';
import 'package:dialect_sdk/src/web3/programs.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  group('Data service api (e2e)', () {
    final baseUrl = programs.mainnet.clusterAddress;
    print("testing with URL: $baseUrl");
    final client = RpcClient(baseUrl);
    test('test get name fail', () async {
      final displayName =
          await tryGetName(client, NAMESPACES_PROGRAM_ID, DEFAULT_PUBKEY);
      expect(displayName, equals(null));
    });

    test('test get name success', () async {
      final handle = "saydialect";
      final pubKey = Ed25519HDPublicKey.fromBase58("");

      final key = await getNameEntry(client, twitterNamespace, handle);
      expect(key.parsed.data, equals(pubKey));

      final entry =
          await getReverseEntry(client, NAMESPACES_PROGRAM_ID, pubKey);
      expect(entry.parsed.entryName, equals(handle));
    });

    test('test get name success', () async {
      final displayName = await tryGetName(
          client, NAMESPACES_PROGRAM_ID, Ed25519HDPublicKey.fromBase58(""));
      expect(displayName, equals("saydialect"));
    });
  });
}
