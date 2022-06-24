import 'dart:convert';

import 'package:dialect_protocol/dialect_protocol.dart';
import 'package:dialect_sdk/src/internal/auth/token-utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data-service-api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/token-provider.dart';
import 'package:dialect_sdk/src/internal/data-service-api/token-store.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-store.dart';
import 'package:dialect_sdk/src/internal/messaging/data-service-messaging.dart';
import 'package:dialect_sdk/src/internal/messaging/messaging-facade.dart';
import 'package:dialect_sdk/src/internal/messaging/solana-messaging.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/sdk/sdk.interface.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter-wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter.interface.dart';
import 'package:solana/solana.dart';

class DialectSdkFactory {
  static const DEFAULT_BACKENDS = [Backend.dialectCloud, Backend.solana];
  final Config config;

  DialectSdkFactory(this.config);

  Future<DialectSdk> create() async {
    final config = _initializeConfig();
    print("Initializing dialect sdk using config:\n ${json.encode(config)}");
    final encryptionKeysProvider = DialectWalletAdapterEncryptionKeysProvider(
        dialectWalletAdapter: config.wallet);
    final messaging = await _createMessaging(config, encryptionKeysProvider);
    return InternalDialectSdk(config.wallet, messaging);
  }

  Future<Messaging> _createMessaging(InternalConfig config,
      DialectWalletAdapterEncryptionKeysProvider encryptionKeysProvider) async {
    List<MessagingBackend> messagingBackends =
        await Future.wait(config.backends.map((backend) async {
      switch (backend) {
        case Backend.solana:
          return MessagingBackend(
              SolanaMessaging(
                  walletAdapter: config.wallet,
                  client: RpcClient(config.solana.rpcUrl),
                  program: (await createDialectProgram(
                      RpcClient(config.solana.rpcUrl),
                      config.solana.dialectProgramAddress)),
                  encryptionKeysProvider: encryptionKeysProvider),
              Backend.solana);
        case Backend.dialectCloud:
          return MessagingBackend(
              DataServiceMessaging(
                  me: config.wallet.publicKey,
                  dataServiceDialectsApi: DataServiceDialectsApiClient(
                      baseUrl: config.dialectCloud.url,
                      tokenProvider: TokenProvider.create(
                          signer: DialectWalletAdapterEd25519TokenSigner(
                              dialectWalletAdapter: config.wallet),
                          ttl: Duration(minutes: 60),
                          tokenStore: config.dialectCloud.tokenStore)),
                  encryptionKeysProvider: encryptionKeysProvider),
              Backend.dialectCloud);
      }
    }));
    return MessagingFacade(messagingBackends);
  }

  List<Backend> _initializeBackends() {
    final backends = config.backends;
    if (backends == null) {
      return DEFAULT_BACKENDS;
    }
    if (backends.isEmpty) {
      throw IllegalArgumentError(title: "Please specify at least one backend");
    }
    return backends;
  }

  InternalConfig _initializeConfig() {
    final environment = config.environment ?? Environment.prod;
    final wallet = DialectWalletAdapterWrapper.create(config.wallet);
    final backends = _initializeBackends();
    final encryptionKeysStore =
        config.encryptionKeysStore ?? InMemoryEncryptionKeysStore();
    return InternalConfig(environment, wallet, _initializeSolanaConfig(),
        _initializeDialectCloudConfig(), encryptionKeysStore, backends);
  }

  InternalDialectCloudConfig _initializeDialectCloudConfig() {
    final internalConfig = InternalDialectCloudConfig(
      DialectCloudEnvironment.prod,
      'https://dialectapi.to',
      InMemoryTokenStore(),
    );
    final environment = config.environment;
    if (environment != null) {
      internalConfig.environment = DialectCloudEnvironment(environment.type);
    }
    if (environment == Environment.prod || environment == Environment.dev) {
      internalConfig.url = 'https://dialectapi.to';
    }
    if (environment == Environment.localDev) {
      internalConfig.url = 'http://localhost:8080';
    }
    final dialectCloudEnvironment = config.dialectCloud?.environment;
    if (dialectCloudEnvironment != null) {
      internalConfig.environment = dialectCloudEnvironment;
    }
    if (dialectCloudEnvironment == DialectCloudEnvironment.prod ||
        dialectCloudEnvironment == DialectCloudEnvironment.dev) {
      internalConfig.url = 'https://dialectapi.to';
    }
    if (dialectCloudEnvironment == DialectCloudEnvironment.localDev) {
      internalConfig.url = 'http://localhost:8080';
    }
    if (config.dialectCloud?.url != null) {
      internalConfig.url = config.dialectCloud!.url!;
    }
    if (config.dialectCloud?.tokenStore != null) {
      internalConfig.tokenStore = config.dialectCloud!.tokenStore!;
    }
    return internalConfig;
  }

  InternalSolanaConfig _initializeSolanaConfig() {
    var internalConfig = InternalSolanaConfig(
      SolanaNetwork.mainnet,
      Ed25519HDPublicKey.fromBase58(programs.mainnet.programAddress),
      programs.mainnet.clusterAddress,
    );
    final environment = config.environment;
    if (environment == Environment.prod) {
      final network = SolanaNetwork.mainnet;
      internalConfig = InternalSolanaConfig(
          network,
          Ed25519HDPublicKey.fromBase58(programs.mainnet.programAddress),
          programs.mainnet.clusterAddress);
    }
    if (environment == Environment.dev) {
      final network = SolanaNetwork.devnet;
      internalConfig = InternalSolanaConfig(
          network,
          Ed25519HDPublicKey.fromBase58(programs.devnet.programAddress),
          programs.devnet.clusterAddress);
    }
    if (environment == Environment.localDev) {
      final network = SolanaNetwork.localnet;
      internalConfig = InternalSolanaConfig(
          network,
          Ed25519HDPublicKey.fromBase58(programs.localnet.programAddress),
          programs.localnet.clusterAddress);
    }
    final solanaNetwork = config.solana?.network;
    if (solanaNetwork == SolanaNetwork.mainnet) {
      final network = SolanaNetwork.mainnet;
      internalConfig = InternalSolanaConfig(
          network,
          Ed25519HDPublicKey.fromBase58(programs.localnet.programAddress),
          programs.localnet.clusterAddress);
    }
    if (solanaNetwork == SolanaNetwork.devnet) {
      final network = SolanaNetwork.devnet;
      internalConfig = InternalSolanaConfig(
          network,
          Ed25519HDPublicKey.fromBase58(programs.devnet.programAddress),
          programs.devnet.clusterAddress);
    }
    if (solanaNetwork == SolanaNetwork.localnet) {
      final network = SolanaNetwork.localnet;
      internalConfig = InternalSolanaConfig(
          network,
          Ed25519HDPublicKey.fromBase58(programs.localnet.programAddress),
          programs.localnet.clusterAddress);
    }

    if (config.solana?.dialectProgramId != null) {
      internalConfig.dialectProgramAddress = config.solana!.dialectProgramId!;
    }
    if (config.solana?.rpcUrl != null) {
      internalConfig.rpcUrl = config.solana!.rpcUrl!;
    }
    return internalConfig;
  }
}

class InternalConfig {
  Environment environment;
  DialectWalletAdapterWrapper wallet;
  InternalSolanaConfig solana;
  InternalDialectCloudConfig dialectCloud;
  EncryptionKeysStore encryptionKeysStore;
  List<Backend> backends;

  InternalConfig(this.environment, this.wallet, this.solana, this.dialectCloud,
      this.encryptionKeysStore, this.backends);
}

class InternalDialectCloudConfig {
  DialectCloudEnvironment environment;
  String url;
  TokenStore tokenStore;
  InternalDialectCloudConfig(this.environment, this.url, this.tokenStore);
}

class InternalDialectSdk extends DialectSdk {
  InternalDialectSdk(CompatibilityProps compatibility, Messaging threads)
      : super(compatibility, threads);
}

class InternalSolanaConfig {
  SolanaNetwork network;
  Ed25519HDPublicKey dialectProgramAddress;
  String rpcUrl;
  InternalSolanaConfig(this.network, this.dialectProgramAddress, this.rpcUrl);
}
