import 'dart:convert';

import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String sessionStorageEncryptionKeysKey = 'dialect-encryption-keys';

abstract class EncryptionKeysStore {
  Future<DiffieHellmanKeys?> get();
  Future<DiffieHellmanKeys> save(DiffieHellmanKeys keys);
  static EncryptionKeysStore createInMemory() {
    return InMemoryEncryptionKeysStore();
  }

  static EncryptionKeysStore createSession() {
    return SessionStorageEncryptionKeysStore();
  }
}

class InMemoryEncryptionKeysStore extends EncryptionKeysStore {
  DiffieHellmanKeys? keys;

  @override
  Future<DiffieHellmanKeys?> get() async {
    return keys;
  }

  @override
  Future<DiffieHellmanKeys> save(DiffieHellmanKeys keys) async {
    this.keys = keys;
    return this.keys!;
  }
}

class SessionStorageEncryptionKeysStore extends EncryptionKeysStore {
  @override
  Future<DiffieHellmanKeys?> get() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString(sessionStorageEncryptionKeysKey);
      return token != null
          ? DiffieHellmanKeys.fromJson(JsonDecoder().convert(token))
          : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<DiffieHellmanKeys> save(DiffieHellmanKeys keys) {
    // TODO: implement save
    throw UnimplementedError();
  }
}
