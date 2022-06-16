import 'dart:typed_data';

import 'package:dialect_sdk/src/core/utils/ed2curve-utils.dart';
import 'package:dialect_sdk/src/core/utils/nacl-utils.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';

const ENCRYPTION_OVERHEAD_BYTES = 16;

Uint8List ecdhDecrypt(Uint8List payload, Curve25519KeyPair keyPair,
    Ed25519Key otherPartyPublicKey, Uint8List nonce) {
  final decrypted = NaClUtils.boxOpen(payload, nonce,
      ed25519PublicKeyToCurve25519(otherPartyPublicKey), keyPair.secretKey);
  if (decrypted == null) {
    throw AuthenticationFailedError();
  }
  return decrypted;
}

Uint8List ecdhEncrypt(Uint8List payload, Curve25519KeyPair keyPair,
    Ed25519Key otherPartyPublicKey, Uint8List nonce) {
  return NaClUtils.box(payload, nonce,
      ed25519PublicKeyToCurve25519(otherPartyPublicKey), keyPair.secretKey);
}

Curve25519KeyPair ed25519KeyPairToCurve25519(Ed25519KeyPair edKeyPair) {
  final curve25519KeyPair =
      Ed2CurveUtils.convertKeyPairOpt(edKeyPair.publicKey, edKeyPair.secretKey);
  if (curve25519KeyPair == null) {
    throw IncorrectPublicKeyFormatError();
  }
  return curve25519KeyPair;
}

Curve25519Key ed25519PublicKeyToCurve25519(Ed25519Key key) {
  final curve25519Key = Ed2CurveUtils.convertPublicKeyOpt(key);
  if (curve25519Key == null) {
    throw IncorrectPublicKeyFormatError();
  }
  return curve25519Key;
}

typedef Curve25519Key = Uint8List;

typedef Ed25519Key = Uint8List;

class AuthenticationFailedError extends DialectSdkError {
  AuthenticationFailedError()
      : super(type: "AuthenticationFailedError", title: "");
}

class Curve25519KeyPair {
  Curve25519Key publicKey;
  Curve25519Key secretKey;

  Curve25519KeyPair(this.publicKey, this.secretKey);
}

class Ed25519KeyPair {
  Ed25519Key publicKey;
  Ed25519Key secretKey;

  Ed25519KeyPair(this.publicKey, this.secretKey);
}

class IncorrectPublicKeyFormatError extends DialectSdkError {
  IncorrectPublicKeyFormatError()
      : super(
            type: "IncorrectPublicKeyFormatError",
            title: "Authentication failed during decryption attempt");
}
