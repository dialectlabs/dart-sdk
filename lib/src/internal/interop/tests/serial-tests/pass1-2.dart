import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:test/test.dart';

import '../../interop-messaging-test-helpers.dart';

// to change timeout, backend, or encryption, edit 'interopTestingConfig' in interop-messaging-test-helpers.dart

void main() async {
  group('Secondary - message 1', () {
    test('Read a thread and reply to primary\'s first message', () async {
      // given
      final factory = await interopTestingConfig.messagingMap.state();

      // find prior conversation
      final existing = await factory.wallet2.messaging.find(
          FindThreadByOtherMemberQuery(
              otherMembers: [factory.wallet1.adapter.publicKey]));
      expect(existing, isNot(equals(null)));

      final existingMessages = await existing!.messages();
      expect(existingMessages.length, equals(1));
      expect(existingMessages.first.text, equals(message1));
      expect(existingMessages.first.author.publicKey.toBase58(),
          equals(factory.wallet1.adapter.publicKey.toBase58()));

      // send and verify second message
      await existing.send(SendMessageCommand(text: message2));
      final wallet2Messages = await existing.messages();
      expect(wallet2Messages.length, equals(2));
      expect(
          wallet2Messages.map((e) => e.author.publicKey.toBase58() + e.text),
          equals([
            factory.wallet1.adapter.publicKey.toBase58() + message1,
            factory.wallet2.adapter.publicKey.toBase58() + message2
          ]));
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));
  }, timeout: Timeout(interopTestingConfig.timeoutDuration));
}
