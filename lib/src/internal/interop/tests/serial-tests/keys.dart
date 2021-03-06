import 'package:dialect_sdk/src/internal/interop/interop-keypairs.dart';
import 'package:test/test.dart';

import '../../interop-messaging-test-helpers.dart';

void main() async {
  group('Keys', () {
    test('Print given keys', () async {
      final primary = await primaryKeyPair;
      final secondary = await secondaryKeyPair;
      print(
          "KEYS: ${primary.publicKey.toBase58()} ${secondary.publicKey.toBase58()}");
      print("KEYS: ${primary.address} ${secondary.address}");
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));
  }, timeout: Timeout(interopTestingConfig.timeoutDuration));
}
