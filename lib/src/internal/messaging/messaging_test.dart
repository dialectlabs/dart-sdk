import 'package:dialect_sdk/src/internal/auth/token-utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data-service-api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/token-provider.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:dialect_sdk/src/internal/messaging/data-service-messaging.dart';
import 'package:dialect_sdk/src/internal/messaging/solana-dialect-program-factory.dart';
import 'package:dialect_sdk/src/internal/messaging/solana-messaging.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter-wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/node-dialect-wallet-adapter.dart';
import 'package:dialect_sdk/src/web3/api/index_test.dart';
import 'package:dialect_sdk/src/web3/programs.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  group('Data service messaging (e2e)', () {
    final messagingMap = [
      MessagingMap("DataServiceMessaging", () => createDataServiceMessaging()),
      MessagingMap("SolanaMessaging", () => createSolanaServiceMessaging())
    ];

    test('can list all threads', () async {
      for (var item in messagingMap) {
        final factory = await item.func();
        final threads = factory.wallet1.messaging.findAll();
        expect(threads, equals([]));
      }
    });
  });
}

const baseUrl = "http://localhost:8080";

Future<MessagingState> createDataServiceMessaging() async {
  final user1Wallet = await NodeDialectWalletAdapter.create();
  final user1WalletAdapter = DialectWalletAdapterWrapper(delegate: user1Wallet);
  final user2Wallet = await NodeDialectWalletAdapter.create();
  final user2WalletAdapter = DialectWalletAdapterWrapper(delegate: user2Wallet);
  final user1DataServiceMessaging = DataServiceMessaging(
      me: user1WalletAdapter.publicKey,
      dataServiceDialectsApi: (DataServiceApi.create(
              baseUrl,
              TokenProvider.create(
                  signer: DialectWalletAdapterEd25519TokenSigner(
                      dialectWalletAdapter: user1WalletAdapter))))
          .threads,
      encryptionKeysProvider: DialectWalletAdapterEncryptionKeysProvider(
          dialectWalletAdapter: user1WalletAdapter));
  final user2DataServiceMessaging = DataServiceMessaging(
      me: user2WalletAdapter.publicKey,
      dataServiceDialectsApi: (DataServiceApi.create(
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
  final walletAdapter = DialectWalletAdapterWrapper(
      delegate: await NodeDialectWalletAdapter.create());
  final program = await createDialectProgram(
      walletAdapter,
      Ed25519HDPublicKey.fromBase58(programs.localnet.programAddress),
      programs.localnet.clusterAddress);
  final client = RpcClient(programs.localnet.clusterAddress);
  final airdropRequest = await client.requestAirdrop(
      walletAdapter.publicKey.toBase58(), LAMPORTS_PER_SOL * 100);
  await client.getTransaction(airdropRequest);
  final userSolanaMessaging =
      SolanaMessaging.createSM(walletAdapter, program, client);
  return WalletMessagingState(walletAdapter, userSolanaMessaging);
}

class MessagingMap {
  String name;
  Future<MessagingState> Function() func;
  MessagingMap(this.name, this.func);
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
