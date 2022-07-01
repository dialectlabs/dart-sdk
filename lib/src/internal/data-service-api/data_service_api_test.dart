import 'package:dialect_sdk/src/internal/data-service-api/data_service_dtos.dart';
import 'package:test/test.dart';

void main() {
  group('Data service api', () {
    group('Dialects', () {
      // TODO: delete after a few rounds of tests
      test('dialect equality test pass - plain case', () async {
        final dialect1 = DialectDto(
            members: [],
            messages: [],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: true);
        final dialect2 = DialectDto(
            members: [],
            messages: [],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: true);
        expect(dialect1, equals(dialect2));
      });

      // TODO: delete after a few rounds of tests
      test('dialect equality test fail - plain case', () async {
        final dialect1 = DialectDto(
            members: [],
            messages: [],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: true);
        final dialect2 = DialectDto(
            members: [],
            messages: [],
            nextMessageIdx: 0,
            lastMessageTimestamp: 1,
            encrypted: true);
        expect(dialect1, isNot(equals(dialect2)));
      });

      // TODO: delete after a few rounds of tests
      test('dialect equality test pass - members case', () async {
        var member1 = MemberDto(publicKey: 'pk1', scopes: []);
        var member2 = MemberDto(publicKey: 'pk1', scopes: []);
        var message1 = MessageDto(owner: 'owner1', text: [], timestamp: 0);
        var message2 = MessageDto(owner: 'owner1', text: [], timestamp: 0);
        final dialect1 = DialectDto(
            members: [member1, member2],
            messages: [message1, message2],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: true);
        final dialect2 = DialectDto(
            members: [],
            messages: [],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: true);
        expect(dialect1, equals(dialect2));
      });

      // TODO: delete after a few rounds of tests
      test('dialect equality test fail - members case', () async {
        var member1 = MemberDto(publicKey: 'pk1', scopes: []);
        var member2 = MemberDto(publicKey: 'pk2', scopes: []);
        var message1 = MessageDto(owner: 'owner1', text: [], timestamp: 0);
        var message2 = MessageDto(owner: 'owner1', text: [], timestamp: 0);
        final dialect1 = DialectDto(
            members: [member1, member2],
            messages: [message1, message2],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: true);
        final dialect2 = DialectDto(
            members: [],
            messages: [],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: true);
        expect(dialect1, isNot(equals(dialect2)));
      });
    });
  });
}
