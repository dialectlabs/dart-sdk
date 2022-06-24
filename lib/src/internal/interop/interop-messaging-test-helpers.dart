import 'package:dialect_protocol/dialect_protocol.dart';
import 'package:dialect_sdk/src/internal/auth/token-utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data-service-api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/token-provider.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:dialect_sdk/src/internal/interop/interop-keypairs.dart' as keys;
import 'package:dialect_sdk/src/internal/messaging/data-service-messaging.dart';
import 'package:dialect_sdk/src/internal/messaging/messaging_test.dart';
import 'package:dialect_sdk/src/internal/messaging/solana-messaging.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter-wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/node-dialect-wallet-adapter.dart';
import 'package:solana/solana.dart';

const baseUrl = "http://localhost:8080";

const message1 = "Hey, bumping you on my offer";
const message2 = "Oh thanks, totally forgot. Btw this chat is slick 😃";
const message3 = "Ikr, not sure how I would've reached you otherwise";

final interopTestingConfig =
    InteroperabilityMessagingConfig.asUnencryptedSolana();

Future<MessagingState> createDataServiceMessaging(
    Future<Ed25519HDKeyPair> primary,
    Future<Ed25519HDKeyPair> secondary) async {
  final user1Wallet =
      await NodeDialectWalletAdapter.create(keypair: await primary);
  final user1WalletAdapter = DialectWalletAdapterWrapper(delegate: user1Wallet);
  final user2Wallet =
      await NodeDialectWalletAdapter.create(keypair: await secondary);
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

Future<MessagingState> createSolanaServiceMessaging(
    Future<Ed25519HDKeyPair> primary,
    Future<Ed25519HDKeyPair> secondary) async {
  final wallets = await Future.wait([
    createSolanaWalletMessagingState(await primary),
    createSolanaWalletMessagingState(await secondary)
  ]);
  return MessagingState(wallets.first, wallets.last);
}

Future<WalletMessagingState> createSolanaWalletMessagingState(
    Ed25519HDKeyPair keyPair) async {
  final client = RpcClient(programs.localnet.clusterAddress);
  final walletAdapter = DialectWalletAdapterWrapper(
      delegate: await NodeDialectWalletAdapter.create(keypair: keyPair));
  final program = await createDialectProgram(
      client, Ed25519HDPublicKey.fromBase58(programs.localnet.programAddress));
  var tx = await client.requestAirdrop(
      walletAdapter.publicKey.toBase58(), LAMPORTS_PER_SOL * 100);
  await waitForFinality(client: client, transactionStr: tx);

  final userSolanaMessaging =
      SolanaMessaging.createSM(walletAdapter, program, client);
  return WalletMessagingState(walletAdapter, userSolanaMessaging);
}

class InteroperabilityMessagingConfig {
  final Duration timeoutDuration = Duration(minutes: 25);
  bool encrypted;
  Backend backend;
  Future<Ed25519HDKeyPair> primaryKeyPair = keys.primaryKeyPair;
  Future<Ed25519HDKeyPair> secondaryKeyPair = keys.secondaryKeyPair;

  InteroperabilityMessagingConfig.asEncryptedDialectCloud()
      : backend = Backend.dialectCloud,
        encrypted = true;
  InteroperabilityMessagingConfig.asEncryptedSolana()
      : backend = Backend.solana,
        encrypted = true;
  InteroperabilityMessagingConfig.asUnencryptedDialectCloud()
      : backend = Backend.dialectCloud,
        encrypted = false;
  InteroperabilityMessagingConfig.asUnencryptedSolana()
      : backend = Backend.solana,
        encrypted = false;

  MessagingMap get messagingMap {
    switch (backend) {
      case Backend.solana:
        return MessagingMap(
            "SolanaMessaging",
            (() => createSolanaServiceMessaging(
                primaryKeyPair, secondaryKeyPair)));
      case Backend.dialectCloud:
        return MessagingMap(
            "DataServiceMessaging",
            (() =>
                createDataServiceMessaging(primaryKeyPair, secondaryKeyPair)));
    }
  }
}

class MessagingMap {
  String name;
  Future<MessagingState> Function() state;
  MessagingMap(this.name, this.state);
}
