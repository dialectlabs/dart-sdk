import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:test/test.dart';

import '../../interop-messaging-test-helpers.dart';

// to change timeout, backend, or encryption, edit 'interopTestingConfig' in interop-messaging-test-helpers.dart

void main() async {
  group('Primary - completion', () {
    test('Attempt to read deleted thread', () async {
      // given
      final factory = await interopTestingConfig.messagingMap.state();

      // find deleted thread
      final deleted = await factory.wallet1.messaging.find(
          FindThreadByOtherMemberQuery(
              otherMembers: [factory.wallet2.adapter.publicKey]));
      expect(deleted, equals(null));
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));
  }, timeout: Timeout(interopTestingConfig.timeoutDuration));
}
