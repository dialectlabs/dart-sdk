import 'package:dialect_sdk/src/internal/data-service-api/token-store.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-store.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter.interface.dart';
import 'package:solana/solana.dart';

class Config {
  Environment? environment;
  DialectWalletAdapter wallet;
  SolanaConfig? solana;
  DialectCloudConfig? dialectCloud;
  EncryptionKeysStore? encryptionKeysStore;
  List<Backend>? backends;

  Config(
      {this.environment,
      required this.wallet,
      this.solana,
      this.dialectCloud,
      this.encryptionKeysStore,
      this.backends});
}

class DialectCloudConfig {
  DialectCloudEnvironment? environment;
  TokenStore? tokenStore;
  String? url;

  DialectCloudConfig({this.environment, this.tokenStore, this.url});
}

class DialectCloudEnvironment {
  static const String _prodType = "production";
  static const String _devType = "development";
  static const String _localType = "local-development";
  static DialectCloudEnvironment get dev => DialectCloudEnvironment(_devType);
  static DialectCloudEnvironment get localDev =>
      DialectCloudEnvironment(_localType);

  static DialectCloudEnvironment get prod => DialectCloudEnvironment(_prodType);
  late String type;
  DialectCloudEnvironment(String value) {
    if (value == _prodType) {
      type = _prodType;
    } else if (value == _devType) {
      type = _devType;
    } else if (value == _localType) {
      type = _localType;
    }
    throw Exception(
        'Unsupported value initializing DialectCloudEnvironment: $value, should equal one of the following: $_prodType, $_devType, $_localType');
  }

  @override
  int get hashCode => Object.hashAll([type]);

  bool get isDev => type == _devType;
  bool get isLocal => type == _localType;

  bool get isProd => type == _prodType;

  @override
  bool operator ==(covariant DialectCloudEnvironment other) =>
      other.type == type;
}

class DialectSdk {
  final CompatibilityProps compatibility;
  final Messaging threads;

  DialectSdk(this.compatibility, this.threads);
}

class Environment {
  static const String _prodType = "production";
  static const String _devType = "development";
  static const String _localType = "local-development";
  static Environment get dev => Environment(_devType);
  static Environment get localDev => Environment(_localType);

  static Environment get prod => Environment(_prodType);
  late String type;
  Environment(String value) {
    if (value == _prodType) {
      type = _prodType;
    } else if (value == _devType) {
      type = _devType;
    } else if (value == _localType) {
      type = _localType;
    }
    throw Exception(
        'Unsupported value initializing Environment: $value, should equal one of the following: $_prodType, $_devType, $_localType');
  }

  @override
  int get hashCode => Object.hashAll([type]);

  bool get isDev => type == _devType;

  bool get isLocal => type == _localType;

  bool get isProd => type == _prodType;

  @override
  bool operator ==(covariant Environment other) => other.type == type;
}

class SolanaConfig {
  SolanaNetwork? network;
  Ed25519HDPublicKey? dialectProgramId;
  String? rpcUrl;

  SolanaConfig({this.network, this.dialectProgramId, this.rpcUrl});
}

class SolanaNetwork {
  static const String _mainType = "mainnet-beta";
  static const String _devType = "devnet";
  static const String _localType = "localnet";

  static SolanaNetwork get devnet => SolanaNetwork(_devType);
  static SolanaNetwork get localnet => SolanaNetwork(_localType);
  static SolanaNetwork get mainnet => SolanaNetwork(_mainType);

  late String type;
  SolanaNetwork(String value) {
    if (value == _mainType) {
      type = _mainType;
    } else if (value == _devType) {
      type = _devType;
    } else if (value == _localType) {
      type = _localType;
    }
    throw Exception(
        'Unsupported value initializing SolanaNetwork: $value, should equal one of the following: $_mainType, $_devType, $_localType');
  }

  @override
  int get hashCode => Object.hashAll([type]);

  bool get isDevnet => type == _devType;

  bool get isLocalnet => type == _localType;

  bool get isMainnet => type == _mainType;

  @override
  bool operator ==(covariant SolanaNetwork other) => other.type == type;
}
