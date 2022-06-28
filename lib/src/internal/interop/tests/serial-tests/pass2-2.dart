import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:test/test.dart';

import '../../interop-messaging-test-helpers.dart';

// to change timeout, backend, or encryption, edit 'interopTestingConfig' in interop-messaging-test-helpers.dart

void main() async {
  group('Secondary - message 2', () {
    test('Read a thread then delete the thread', () async {
      // given
      final factory = await interopTestingConfig.messagingMap.state();

      // find prior conversation
      final existing = await factory.wallet2.messaging.find(
          FindThreadByOtherMemberQuery(
              otherMembers: [factory.wallet1.adapter.publicKey]));
      expect(existing, isNot(equals(null)));

      final existingMessages = await existing!.messages();
      expect(existingMessages.length, equals(3));
      expect(
          existingMessages.map((e) => e.author.publicKey.toBase58() + e.text),
          equals([
            factory.wallet1.adapter.publicKey.toBase58() + message1,
            factory.wallet2.adapter.publicKey.toBase58() + message2,
            factory.wallet1.adapter.publicKey.toBase58() + message3
          ]));

      // delete
      await existing.delete();
      final deleted = await factory.wallet2.messaging.find(
          FindThreadByOtherMemberQuery(
              otherMembers: [factory.wallet1.adapter.publicKey]));
      expect(deleted, equals(null));
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));
  }, timeout: Timeout(interopTestingConfig.timeoutDuration));
}
