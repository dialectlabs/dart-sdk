import 'package:dialect_sdk/src/core/converters/uint8list-converter.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-store.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter-wrapper.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pinenacl/ed25519.dart';

part 'encryption-keys-provider.g.dart';

class CachedEncryptionKeysProvider extends EncryptionKeysProvider {
  final EncryptionKeysProvider _delegate;
  final EncryptionKeysStore _encryptionKeysStore;

  Future<DiffieHellmanKeys?>? _delegateGetPromise;

  CachedEncryptionKeysProvider._(this._delegate, this._encryptionKeysStore);

  @override
  Future<DiffieHellmanKeys> getFailFast() async {
    final existingKeys = await _encryptionKeysStore.get();
    if (existingKeys == null) {
      final newKeys = await _delegate.getFailFast();
      return _encryptionKeysStore.save(newKeys);
    }
    return existingKeys;
  }

  @override
  Future<DiffieHellmanKeys?> getFailSafe() async {
    final existingKeys = await _encryptionKeysStore.get();
    if (existingKeys != null) {
      _delegateGetPromise = null;
      return existingKeys;
    }
    _delegateGetPromise ??= _delegate.getFailSafe().then((value) {
      if (value != null) {
        _encryptionKeysStore.save(value);
      }
      return null;
    });
    return _delegateGetPromise;
  }

  static CachedEncryptionKeysProvider create(
      EncryptionKeysProvider delegate, EncryptionKeysStore store) {
    return CachedEncryptionKeysProvider._(delegate, store);
  }
}

class DialectWalletAdapterEncryptionKeysProvider
    extends EncryptionKeysProvider {
  final DialectWalletAdapterWrapper dialectWalletAdapter;
  DialectWalletAdapterEncryptionKeysProvider(
      {required this.dialectWalletAdapter});

  @override
  Future<DiffieHellmanKeys> getFailFast() async {
    return dialectWalletAdapter.diffieHellman!();
  }

  @override
  Future<DiffieHellmanKeys?> getFailSafe() async {
    return dialectWalletAdapter.canEncrypt()
        ? (await dialectWalletAdapter.diffieHellman!())
        : null;
  }
}

@JsonSerializable(explicitToJson: true)
@Uint8ListConverter()
class DiffieHellmanKeys {
  @JsonKey(name: "publicKey")
  final Uint8List publicKey;
  @JsonKey(name: "secretKey")
  final Uint8List secretKey;
  DiffieHellmanKeys({required this.publicKey, required this.secretKey});

  factory DiffieHellmanKeys.fromJson(Map<String, dynamic> json) =>
      _$DiffieHellmanKeysFromJson(json);

  Map<String, dynamic> toJson() => _$DiffieHellmanKeysToJson(this);
}

abstract class EncryptionKeysProvider {
  Future<DiffieHellmanKeys> getFailFast();
  Future<DiffieHellmanKeys?> getFailSafe();
  static EncryptionKeysProvider create(
      {required DialectWalletAdapterWrapper dialectWalletAdapter,
      EncryptionKeysStore? encryptionKeysStore}) {
    final eKeyStore = encryptionKeysStore ?? InMemoryEncryptionKeysStore();
    final provider = DialectWalletAdapterEncryptionKeysProvider(
        dialectWalletAdapter: dialectWalletAdapter);
    return CachedEncryptionKeysProvider.create(provider, eKeyStore);
  }
}
