import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:test/test.dart';

import '../../interop_messaging_test_helpers.dart';

// to change timeout, backend, or encryption, edit 'interopTestingConfig' in interop-messaging-test-helpers.dart

void main() async {
  group('Primary - message 1', () {
    test('Create a thread and send a message', () async {
      // given
      final factory = await interopTestingConfig.messagingMap.state();

      // // reset conversation from any prior tests
      final existing = await factory.wallet1.messaging.find(
          FindThreadByOtherMemberQuery(
              otherMembers: [factory.wallet2.adapter.publicKey]));
      if (existing != null) {
        await existing.delete();
        final deleted = await factory.wallet1.messaging.find(
            FindThreadByOtherMemberQuery(
                otherMembers: [factory.wallet2.adapter.publicKey]));
        expect(deleted, equals(null));
      }

      // // create new conversation
      final command = CreateThreadCommand(
          me: ThreadMemberPartial(
              scopes: [ThreadMemberScope.admin, ThreadMemberScope.write]),
          otherMembers: [
            ThreadMember(
                publicKey: factory.wallet2.adapter.publicKey,
                scopes: [ThreadMemberScope.admin, ThreadMemberScope.write])
          ],
          encrypted: interopTestingConfig.encrypted);
      final thread = await factory.wallet1.messaging.create(command);
      expect(thread, isNot(equals(null)));

      // send and verify message
      await thread.send(SendMessageCommand(text: message1));
      final wallet1Messages = await thread.messages();
      expect(wallet1Messages.length, equals(1));
      expect(wallet1Messages.first.text, equals(message1));
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));
  }, timeout: Timeout(interopTestingConfig.timeoutDuration));
}
