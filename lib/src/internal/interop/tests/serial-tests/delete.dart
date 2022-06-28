import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:test/test.dart';

import '../../interop-messaging-test-helpers.dart';

void main() async {
  group('Delete', () {
    test('Delete existing thread', () async {
      // given
      final factory = await interopTestingConfig.messagingMap.state();

      // // reset conversation from any prior tests
      var existing = await factory.wallet1.messaging.find(
          FindThreadByOtherMemberQuery(
              otherMembers: [factory.wallet2.adapter.publicKey]));
      print(existing == null ? "Already deleted" : "Not yet deleted");
      if (existing != null) {
        await existing.delete();
        existing = await factory.wallet1.messaging.find(
            FindThreadByOtherMemberQuery(
                otherMembers: [factory.wallet2.adapter.publicKey]));
      }
      expect(existing, equals(null));
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));
  }, timeout: Timeout(interopTestingConfig.timeoutDuration));
}
