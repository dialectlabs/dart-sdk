import 'dart:convert';

import 'package:dialect_sdk/src/internal/auth/token-utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data-service-api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dtos/data-service-dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/token-provider.dart';
import 'package:dialect_sdk/src/wallet-adapter/node-dialect-wallet-adapter.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  group('Data service api (e2e)', () {
    const baseUrl = "http://localhost:8080";

    group('Dialects', () {
      late NodeDialectWalletAdapter wallet1;
      late DataServiceDialectsApi wallet1Api;
      late NodeDialectWalletAdapter wallet2;
      late DataServiceDialectsApi wallet2Api;
      setUp(() async {
        wallet1 = await NodeDialectWalletAdapter.create();
        wallet2 = await NodeDialectWalletAdapter.create();
        wallet1Api = DataServiceApi.create(
          baseUrl,
          TokenProvider.create(
            signer: DialectWalletAdapterEd25519TokenSigner(
                dialectWalletAdapter: wallet1),
          ),
        ).threads;
        wallet2Api = DataServiceApi.create(
          baseUrl,
          TokenProvider.create(
            signer: DialectWalletAdapterEd25519TokenSigner(
                dialectWalletAdapter: wallet2),
          ),
        ).threads;
      });

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

      test('can list all dialects', () async {
        // when
        final dialects = await wallet1Api.findAll();

        // then
        expect(dialects, equals([]));
      });

      test('wallet-adapter cannot create dialect not being a member', () async {
        await expectLater(
            wallet1Api.create(CreateDialectCommand(members: [
              PostMemberDto(
                  publicKey: (await (await Ed25519HDKeyPair.random())
                          .extractPublicKey())
                      .toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
              PostMemberDto(
                  publicKey: (await (await Ed25519HDKeyPair.random())
                          .extractPublicKey())
                      .toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
            ], encrypted: false)),
            throwsException);
      });

      test('wallet-adapter cannot create dialect with less than 2 members',
          () async {
        await expectLater(
            wallet1Api.create(CreateDialectCommand(members: [
              PostMemberDto(
                  publicKey: wallet1.publicKey.toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
            ], encrypted: false)),
            throwsException);
      });

      test('wallet-adapter cannot create dialect with more than 2 members',
          () async {
        await expectLater(
            wallet1Api.create(CreateDialectCommand(members: [
              PostMemberDto(
                  publicKey: wallet1.publicKey.toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
              PostMemberDto(
                  publicKey: (await (await Ed25519HDKeyPair.random())
                          .extractPublicKey())
                      .toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
              PostMemberDto(
                  publicKey: (await (await Ed25519HDKeyPair.random())
                          .extractPublicKey())
                      .toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
            ], encrypted: false)),
            throwsException);
      });

      test('wallet-adapter cannot create dialect with duplicate member',
          () async {
        await expectLater(
            wallet1Api.create(CreateDialectCommand(members: [
              PostMemberDto(
                  publicKey: wallet1.publicKey.toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
              PostMemberDto(
                  publicKey: wallet1.publicKey.toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
            ], encrypted: false)),
            throwsException);
      });

      test(
          'wallet-adapter cannot create dialect when member public key is invalid',
          () async {
        await expectLater(
            wallet1Api.create(CreateDialectCommand(members: [
              PostMemberDto(
                  publicKey: wallet1.publicKey.toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
              PostMemberDto(
                  publicKey: 'invalid-public-key',
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
            ], encrypted: false)),
            throwsException);
      });

      test('wallet-adapter cannot create dialect with same members', () async {
        final createDialectCommand = CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: wallet1.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
          PostMemberDto(
              publicKey:
                  (await (await Ed25519HDKeyPair.random()).extractPublicKey())
                      .toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
        ], encrypted: false);
        await expectLater(wallet1Api.create(createDialectCommand), completes);
        await expectLater(
            wallet1Api.create(createDialectCommand), throwsException);
      });

      test('wallet-adapter cannot create dialect not being an admin', () async {
        await expectLater(
            wallet1Api.create(CreateDialectCommand(members: [
              PostMemberDto(
                  publicKey: wallet1.publicKey.toBase58(),
                  scopes: [MemberScopeDto.write]),
              PostMemberDto(
                  publicKey: (await (await Ed25519HDKeyPair.random())
                          .extractPublicKey())
                      .toBase58(),
                  scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
            ], encrypted: false)),
            throwsException);
      });

      test('can create dialect', () async {
        // given
        final before = await wallet1Api.findAll();
        expect(before, equals([]));

        // when
        final command = CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: wallet1.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
          PostMemberDto(
              publicKey:
                  (await (await Ed25519HDKeyPair.random()).extractPublicKey())
                      .toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
        ], encrypted: false);
        final dialectAccount = await wallet1Api.create(command);

        // then
        expect(dialectAccount.publicKey, isNotNull);
        final expectedDialect = DialectDto.fromPostMembers(
            postMembers: command.members,
            messages: [],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: command.encrypted);
        expect(dialectAccount.dialect, equals(expectedDialect));
      });

      test('admin can delete dialect', () async {
        // given
        final command = CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: wallet1.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
          PostMemberDto(
              publicKey: wallet2.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
        ], encrypted: false);

        // when
        final dialectAccount = await wallet1Api.create(command);
        await expectLater(wallet2Api.find(dialectAccount.publicKey), completes);

        // then
        await wallet2Api.delete(dialectAccount.publicKey);
        await expectLater(
            wallet2Api.find(dialectAccount.publicKey), throwsException);
      });

      test('admin cannot delete dialect', () async {
        // given
        final command = CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: wallet1.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
          PostMemberDto(
              publicKey: wallet2.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin]),
        ], encrypted: false);

        // when
        final dialectAccount = await wallet1Api.create(command);
        await expectLater(wallet2Api.find(dialectAccount.publicKey), completes);

        // then
        await expectLater(
            wallet2Api.delete(dialectAccount.publicKey), throwsException);
      });

      test('can list all dialects after creating', () async {
        // given
        final before = await wallet1Api.findAll();
        expect(before, equals([]));
        final createDialect1Command = CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: wallet1.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
          PostMemberDto(
              publicKey:
                  (await (await Ed25519HDKeyPair.random()).extractPublicKey())
                      .toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
        ], encrypted: false);

        final createDialect2Command = CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: wallet1.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
          PostMemberDto(
              publicKey:
                  (await (await Ed25519HDKeyPair.random()).extractPublicKey())
                      .toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
        ], encrypted: false);

        // when
        await Future.wait([
          wallet1Api.create(createDialect1Command),
          wallet1Api.create(createDialect2Command)
        ]);
        final dialectAccountDtos = await wallet1Api.findAll();

        // then
        expect(dialectAccountDtos.length, equals(2));
        final dialectAccountDto1 = dialectAccountDtos[0];
        final dialectAccountDto2 = dialectAccountDtos[1];
        expect(dialectAccountDto1, isNot(equals(null)));
        expect(dialectAccountDto1!.publicKey,
            isNot(equals(dialectAccountDto2!.publicKey)));
        final actualDialects =
            Set.from(dialectAccountDtos.map((e) => e!.dialect));
        final expectedDialects = {
          DialectDto.fromPostMembers(
              messages: [],
              postMembers: createDialect1Command.members,
              encrypted: createDialect1Command.encrypted,
              lastMessageTimestamp: 0,
              nextMessageIdx: 0),
          DialectDto.fromPostMembers(
              messages: [],
              postMembers: createDialect2Command.members,
              encrypted: createDialect2Command.encrypted,
              lastMessageTimestamp: 0,
              nextMessageIdx: 0),
        };
        expect(actualDialects, equals(expectedDialects));
      });

      test('can get dialect by key after creating', () async {
        // given
        final before = await wallet1Api.findAll();
        expect(before, equals([]));

        final createDialectCommand = CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: wallet1.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
          PostMemberDto(
              publicKey:
                  (await (await Ed25519HDKeyPair.random()).extractPublicKey())
                      .toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
        ], encrypted: false);

        // when
        final dialectAccount = await wallet1Api.create(createDialectCommand);
        final dialectAccountDto =
            await wallet1Api.find(dialectAccount.publicKey);

        // then
        expect(dialectAccountDto, isNot(equals(null)));
        final actualDialectPublicKey = dialectAccountDto!.publicKey;
        final actualDialect = dialectAccountDto.dialect;
        expect(actualDialectPublicKey, equals(dialectAccount.publicKey));
        final expectedDialectDto = DialectDto.fromPostMembers(
            postMembers: createDialectCommand.members,
            messages: [],
            nextMessageIdx: 0,
            lastMessageTimestamp: 0,
            encrypted: createDialectCommand.encrypted);
        expect(actualDialect, equals(expectedDialectDto));
      });

      test('can send message to dialect', () async {
        // given
        final createDialectCommand = CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: wallet1.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
          PostMemberDto(
              publicKey: wallet2.publicKey.toBase58(),
              scopes: [MemberScopeDto.admin, MemberScopeDto.write]),
        ], encrypted: true);

        // when
        final dialectAccount = await wallet1Api.create(createDialectCommand);
        final sendMessageCommand1 = SendMessageCommand(
            Uint8List.fromList(utf8.encode('Hello world 💬')));
        await wallet1Api.sendMessage(
            dialectAccount.publicKey, sendMessageCommand1);
        final sendMessageCommand2 =
            SendMessageCommand(Uint8List.fromList(utf8.encode('Hello world')));
        final dialectAccountDto = (await wallet1Api.sendMessage(
            dialectAccount.publicKey, sendMessageCommand1));

        // then
        expect(dialectAccountDto, isNot(equals(null)));
        final actualDialectPublicKey = dialectAccountDto!.publicKey;
        final actualDialect = dialectAccountDto.dialect;
        expect(actualDialectPublicKey, equals(dialectAccount.publicKey));

        final messages = Set.from(actualDialect.messages
            .map((e) => {'text': e.text, 'owner': e.owner}));
        final expectedMessages = {
          {
            'text': sendMessageCommand1.text,
            'owner': wallet1.publicKey.toBase58()
          },
          {
            'text': sendMessageCommand2.text,
            'owner': wallet2.publicKey.toBase58()
          }
        };
        expect(messages, equals(expectedMessages));
      });
    });
  });
}
