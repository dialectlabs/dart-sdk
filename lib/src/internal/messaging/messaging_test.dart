import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/auth/token_utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart'
    as api;
import 'package:dialect_sdk/src/internal/encryption/encryption_keys_provider.dart';
import 'package:dialect_sdk/src/internal/messaging/data_service_messaging.dart';
import 'package:dialect_sdk/src/internal/messaging/solana_dialect_program_factory.dart';
import 'package:dialect_sdk/src/internal/messaging/solana_messaging.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect_wallet_adapter_wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/node_dialect_wallet_adapter.dart';
import 'package:dialect_web3/dialect_web3.dart' as web3;
import 'package:solana/solana.dart' as sol;
import 'package:test/test.dart';

void main() async {
  final timeout = Timeout(Duration(minutes: 25));

  group('Data service messaging (e2e)', () {
    final List<MessagingMap> messagingMap = [];

    setUp(() async {
      messagingMap.add(
          MessagingMap("DataServiceMessaging", createDataServiceMessaging));
      // messagingMap
      //     .add(MessagingMap("SolanaMessaging", createSolanaServiceMessaging));
    });
    test('can list all threads', () async {
      for (var item in messagingMap) {
        // given
        final factory = await item.state();
        // when
        final threads = await factory.wallet1.messaging.findAll();
        // then
        expect(threads, equals([]));
      }
    }, timeout: timeout);

    test('can create thread', () async {
      for (var item in messagingMap) {
        // given
        final factory = await item.state();
        final before = await factory.wallet1.messaging.findAll();
        expect(before, equals([]));
        // when
        final command = CreateThreadCommand(
            me: ThreadMemberPartial(
                scopes: [ThreadMemberScope.admin, ThreadMemberScope.write]),
            otherMembers: [
              ThreadMember(
                  publicKey: factory.wallet2.adapter.publicKey,
                  scopes: [ThreadMemberScope.admin, ThreadMemberScope.write])
            ],
            encrypted: false);
        final thread = await factory.wallet1.messaging.create(command);
        expect(thread, isNot(equals(null)));
      }
    }, timeout: timeout);

    test('cannot create encrypted thread if encryption not supported',
        () async {
      for (var item in messagingMap) {
        // given
        final factory = await item.state();
        final before = await factory.wallet1.messaging.findAll();
        expect(before, equals([]));
        // when
        final command = CreateThreadCommand(
            me: ThreadMemberPartial(
                scopes: [ThreadMemberScope.admin, ThreadMemberScope.write]),
            otherMembers: [
              ThreadMember(
                  publicKey: factory.wallet2.adapter.publicKey,
                  scopes: [ThreadMemberScope.admin, ThreadMemberScope.write])
            ],
            encrypted: true);
        factory.wallet1.adapter.diffieHellman = null;
        await expectLater(
            factory.wallet1.messaging.create(command), throwsException);
      }
    }, timeout: timeout);

    test('admin can delete thread', () async {
      for (var item in messagingMap) {
        // given
        final factory = await item.state();
        // when
        final command = CreateThreadCommand(
            me: ThreadMemberPartial(
                scopes: [ThreadMemberScope.admin, ThreadMemberScope.write]),
            otherMembers: [
              ThreadMember(
                  publicKey: factory.wallet2.adapter.publicKey,
                  scopes: [ThreadMemberScope.admin, ThreadMemberScope.write])
            ],
            encrypted: false);
        final thread = await factory.wallet1.messaging.create(command);
        final actual = await factory.wallet2.messaging.find(FindThreadByIdQuery(
            id: ThreadId(thread.publicKey, thread.backend)));
        expect(actual, isNot(equals(null)));
        await thread.delete();
        final afterDeletion = await factory.wallet2.messaging.find(
            FindThreadByIdQuery(
                id: ThreadId(thread.publicKey, thread.backend)));
        expect(afterDeletion, equals(null));
      }
    }, timeout: timeout);

    test('can find all threads after creating', () async {
      for (var item in messagingMap) {
        // given
        final factory = await item.state();
        // when
        final command = CreateThreadCommand(
            me: ThreadMemberPartial(
                scopes: [ThreadMemberScope.admin, ThreadMemberScope.write]),
            otherMembers: [
              ThreadMember(
                  publicKey: factory.wallet2.adapter.publicKey,
                  scopes: [ThreadMemberScope.admin, ThreadMemberScope.write])
            ],
            encrypted: false);
        await factory.wallet1.messaging.create(command);
        final wallet1Dialects = await factory.wallet1.messaging.findAll();
        final wallet2Dialects = await factory.wallet2.messaging.findAll();
        expect(wallet1Dialects.length, equals(1));
        expect(wallet2Dialects.length, equals(1));
      }
    }, timeout: timeout);

    test('can send/receive message when thread is unencrypted', () async {
      for (var item in messagingMap) {
        // given
        final factory = await item.state();
        // when
        final command = CreateThreadCommand(
            me: ThreadMemberPartial(
                scopes: [ThreadMemberScope.admin, ThreadMemberScope.write]),
            otherMembers: [
              ThreadMember(
                  publicKey: factory.wallet2.adapter.publicKey,
                  scopes: [ThreadMemberScope.admin, ThreadMemberScope.write])
            ],
            encrypted: false);
        final wallet1Dialect = await factory.wallet1.messaging.create(command);
        final wallet2Dialect = (await factory.wallet2.messaging.find(
            FindThreadByIdQuery(
                id: ThreadId(
                    wallet1Dialect.publicKey, wallet1Dialect.backend))))!;
        await wallet1Dialect.send(SendMessageCommand(text: "Hello world 💬"));
        await wallet2Dialect.send(SendMessageCommand(text: "Hello world"));
        // then
        final Set<Message> wallet1Messages =
            Set.from(await wallet1Dialect.messages());
        final Set<Message> wallet2Messages =
            Set.from(await wallet2Dialect.messages());
        // print("W1: ${wallet1Messages.map((e) => "${e.text} ${e.timestamp}")}");
        // print("W2: ${wallet2Messages.map((e) => "${e.text} ${e.timestamp}")}");
        expect(wallet1Messages.length, equals(2));
        expect(wallet2Messages.length, equals(2));
        expect(wallet1Messages.map((e) => e.hashCode),
            equals(wallet2Messages.map((e) => e.hashCode)));
      }
    }, timeout: timeout);

    test('can send/receive message when thread is encrypted', () async {
      for (var item in messagingMap) {
        // given
        final factory = await item.state();
        // when
        final command = CreateThreadCommand(
            me: ThreadMemberPartial(
                scopes: [ThreadMemberScope.admin, ThreadMemberScope.write]),
            otherMembers: [
              ThreadMember(
                  publicKey: factory.wallet2.adapter.publicKey,
                  scopes: [ThreadMemberScope.admin, ThreadMemberScope.write])
            ],
            encrypted: true);
        final wallet1Dialect = await factory.wallet1.messaging.create(command);
        final wallet2Dialect = (await factory.wallet2.messaging.find(
            FindThreadByIdQuery(
                id: ThreadId(
                    wallet1Dialect.publicKey, wallet1Dialect.backend))))!;
        final sendMessageCommand = SendMessageCommand(text: "Hello world 💬");
        await wallet1Dialect.send(sendMessageCommand);
        // then
        final wallet1Messages = await wallet1Dialect.messages();
        final wallet2Messages = await wallet2Dialect.messages();
        // print("W1: ${wallet1Messages.map((e) => "${e.text} ${e.timestamp}")}");
        // print("W2: ${wallet2Messages.map((e) => "${e.text} ${e.timestamp}")}");
        expect(wallet1Messages.length, equals(1));
        expect(wallet1Messages.first.text, equals(sendMessageCommand.text));
        expect(Set<int>.from(wallet1Messages.map((e) => e.hashCode)),
            equals(Set<int>.from(wallet2Messages.map((e) => e.hashCode))));
      }
    }, timeout: timeout);

    test(
        'can send message, but cannot read it if wallet does not support encryption',
        () async {
      for (var item in messagingMap) {
        // given
        final factory = await item.state();
        factory.wallet2.adapter.diffieHellman = null;
        final command = CreateThreadCommand(
            me: ThreadMemberPartial(
                scopes: [ThreadMemberScope.admin, ThreadMemberScope.write]),
            otherMembers: [
              ThreadMember(
                  publicKey: factory.wallet2.adapter.publicKey,
                  scopes: [ThreadMemberScope.admin, ThreadMemberScope.write])
            ],
            encrypted: true);
        // when
        final wallet1Dialect = await factory.wallet1.messaging.create(command);
        final wallet2Dialect = (await factory.wallet2.messaging.find(
            FindThreadByIdQuery(
                id: ThreadId(
                    wallet1Dialect.publicKey, wallet1Dialect.backend))))!;
        final sendMessageCommand = SendMessageCommand(text: "Hello world 💬");
        await wallet1Dialect.send(sendMessageCommand);
        // then
        expect(wallet1Dialect.encryptionEnabled, equals(true));
        expect(wallet1Dialect.canBeDecrypted, equals(true));
        final wallet1Messages = await wallet1Dialect.messages();
        final wallet2Messages = await wallet2Dialect.messages();
        expect(wallet2Dialect.encryptionEnabled, equals(true));
        expect(wallet2Dialect.canBeDecrypted, equals(false));
        expect(wallet1Messages.length, equals(1));
        expect(wallet1Messages.first.text, equals(sendMessageCommand.text));
        expect(wallet2Messages.length, equals(0));
      }
    }, timeout: timeout);

    group('Logic testing', () {
      test('test encryption logic', () async {
        final wallet1 = await NodeDialectWalletAdapter.create();
        final encryptionProps1 = (await getEncryptionProps(
            wallet1.publicKey, await wallet1.diffieHellman!()))!;
        final wallet2 = await NodeDialectWalletAdapter.create();
        final encryptionProps2 = (await getEncryptionProps(
            wallet2.publicKey, await wallet2.diffieHellman!()))!;

        final message = "Hello world";

        final serde1 = web3.EncryptedTextSerde(
            encryptionProps: encryptionProps1,
            members: [wallet1.publicKey, wallet2.publicKey]);
        final serde2 = web3.EncryptedTextSerde(
            encryptionProps: encryptionProps2,
            members: [wallet1.publicKey, wallet2.publicKey]);

        var encryptedMessage = serde1.serialize(message);
        var decryptedMessage = serde2.deserialize(encryptedMessage);

        expect(decryptedMessage, equals(message));
      }, timeout: timeout);
    });
  }, timeout: timeout);
}

const baseUrl = "http://localhost:8080";

Future<MessagingState> createDataServiceMessaging() async {
  final user1Wallet = await NodeDialectWalletAdapter.create();
  final user1WalletAdapter = DialectWalletAdapterWrapper(delegate: user1Wallet);
  final user2Wallet = await NodeDialectWalletAdapter.create();
  final user2WalletAdapter = DialectWalletAdapterWrapper(delegate: user2Wallet);
  final user1DataServiceMessaging = DataServiceMessaging(
      me: user1WalletAdapter.publicKey,
      dataServiceDialectsApi: (api.DataServiceApi.create(
              baseUrl,
              TokenProvider.create(
                  signer: DialectWalletAdapterEd25519TokenSigner(
                      dialectWalletAdapter: user1WalletAdapter))))
          .threads,
      encryptionKeysProvider: DialectWalletAdapterEncryptionKeysProvider(
          dialectWalletAdapter: user1WalletAdapter));
  final user2DataServiceMessaging = DataServiceMessaging(
      me: user2WalletAdapter.publicKey,
      dataServiceDialectsApi: (api.DataServiceApi.create(
              baseUrl,
              TokenProvider.create(
                  signer: DialectWalletAdapterEd25519TokenSigner(
                      dialectWalletAdapter: user2WalletAdapter))))
          .threads,
      encryptionKeysProvider: DialectWalletAdapterEncryptionKeysProvider(
          dialectWalletAdapter: user2WalletAdapter));
  return MessagingState(
      WalletMessagingState(user1WalletAdapter, user1DataServiceMessaging),
      WalletMessagingState(user2WalletAdapter, user2DataServiceMessaging));
}

Future<MessagingState> createSolanaServiceMessaging() async {
  final wallets = await Future.wait(
      [createSolanaWalletMessagingState(), createSolanaWalletMessagingState()]);
  return MessagingState(wallets.first, wallets.last);
}

Future<WalletMessagingState> createSolanaWalletMessagingState() async {
  final client = sol.RpcClient(web3.programs.localnet.clusterAddress);
  final walletAdapter = DialectWalletAdapterWrapper(
      delegate: await NodeDialectWalletAdapter.create());
  final program = await createDialectProgram(client,
      sol.Ed25519HDPublicKey.fromBase58(web3.programs.localnet.programAddress));
  var tx = await client.requestAirdrop(
      walletAdapter.publicKey.toBase58(), web3.LAMPORTS_PER_SOL * 100);
  await web3.waitForFinality(client: client, transactionStr: tx);

  final userSolanaMessaging =
      SolanaMessaging.createSM(walletAdapter, program, client);
  return WalletMessagingState(walletAdapter, userSolanaMessaging);
}

class MessagingMap {
  String name;
  Future<MessagingState> Function() state;
  MessagingMap(this.name, this.state);
}

class MessagingState {
  WalletMessagingState wallet1;
  WalletMessagingState wallet2;
  MessagingState(this.wallet1, this.wallet2);
}

class WalletMessagingState {
  DialectWalletAdapterWrapper adapter;
  Messaging messaging;

  WalletMessagingState(this.adapter, this.messaging);
}
