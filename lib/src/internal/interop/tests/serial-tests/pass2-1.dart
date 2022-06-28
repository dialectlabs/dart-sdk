import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:test/test.dart';

import '../../interop-messaging-test-helpers.dart';

// to change timeout, backend, or encryption, edit 'interopTestingConfig' in interop-messaging-test-helpers.dart

void main() async {
  group('Primary - message 2', () {
    test('Read a thread and reply to secondary\'s first message', () async {
      // given
      final factory = await interopTestingConfig.messagingMap.state();

      // find prior conversation
      final existing = await factory.wallet1.messaging.find(
          FindThreadByOtherMemberQuery(
              otherMembers: [factory.wallet2.adapter.publicKey]));
      expect(existing, isNot(equals(null)));

      final existingMessages = await existing!.messages();
      expect(existingMessages.length, equals(2));
      expect(
          existingMessages.map((e) => e.author.publicKey.toBase58() + e.text),
          equals([
            factory.wallet1.adapter.publicKey.toBase58() + message1,
            factory.wallet2.adapter.publicKey.toBase58() + message2
          ]));

      // send and verify third message
      await existing.send(SendMessageCommand(text: message3));
      final wallet1Messages = await existing.messages();
      expect(wallet1Messages.length, equals(3));
      expect(
          wallet1Messages.map((e) => e.author.publicKey.toBase58() + e.text),
          equals([
            factory.wallet1.adapter.publicKey.toBase58() + message1,
            factory.wallet2.adapter.publicKey.toBase58() + message2,
            factory.wallet1.adapter.publicKey.toBase58() + message3
          ]));
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));
  }, timeout: Timeout(interopTestingConfig.timeoutDuration));
}
