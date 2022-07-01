import 'package:json_annotation/json_annotation.dart';
import 'package:solana/solana.dart';

class Ed25519PublicKeyConverter
    implements JsonConverter<Ed25519HDPublicKey, String> {
  const Ed25519PublicKeyConverter();

  @override
  Ed25519HDPublicKey fromJson(String key) {
    return Ed25519HDPublicKey.fromBase58(key);
  }

  @override
  String toJson(Ed25519HDPublicKey object) {
    return object.toBase58();
  }
}

class OptionalEd25519PublicKeyConverter
    implements JsonConverter<Ed25519HDPublicKey?, String?> {
  static Ed25519PublicKeyConverter ed25519PublicKeyConverter =
      const Ed25519PublicKeyConverter();

  const OptionalEd25519PublicKeyConverter();

  @override
  Ed25519HDPublicKey? fromJson(String? map) {
    if (map == null) {
      return null;
    }
    return ed25519PublicKeyConverter.fromJson(map);
  }

  @override
  String? toJson(Ed25519HDPublicKey? list) {
    if (list == null) {
      return null;
    }
    return ed25519PublicKeyConverter.toJson(list);
  }
}
