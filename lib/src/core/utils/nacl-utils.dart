import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/tweetnacl.dart';
import 'package:solana/solana.dart';

class NaClUtils {
  // implementation of js complement: nacl.sign.detached
  static Uint8List sign(Uint8List message, Uint8List secret) {
    if (secret.length != TweetNaCl.signatureLength) {
      throw Exception('bad secret key size');
    }
    var signedMessage = Uint8List(TweetNaCl.signatureLength + message.length);
    var _ = TweetNaCl.crypto_sign(signedMessage, -1,
        Uint8List.fromList(message), 0, message.length, secret);
    return signedMessage;
  }

  static Uint8List signDetached(Uint8List message, Uint8List secret) {
    final signedMessage = sign(message, secret);
    return Uint8List.fromList(
        signedMessage.take(TweetNaCl.signatureLength).toList());
  }

  // implementation of js complement: nacl.sign.detached.verify
  static bool signDetachedVerify(
      Uint8List message, Uint8List signature, Uint8List publicKey) {
    if (signature.length != TweetNaCl.signatureLength) {
      print(signature.length);
      print(TweetNaCl.signatureLength);
      throw Exception('bad signature size');
    }
    if (publicKey.length != TweetNaCl.publicKeyLength) {
      throw Exception('bad public key size');
    }
    var sm = Uint8List.fromList(signature.toList() + message.toList());
    var m = Uint8List(TweetNaCl.signatureLength + message.length);
    return TweetNaCl.crypto_sign_open(m, 0, sm, 0, sm.length, publicKey) >= 0;
  }

  static Future<Ed25519HDKeyPair> signKeypair() async {
    var pk = Uint8List(TweetNaCl.publicKeyLength);
    var sk = Uint8List(TweetNaCl.signingKeyLength);
    final _ = TweetNaCl.crypto_sign_keypair(pk, sk, TweetNaCl.randombytes(32));
    var privateKey = SigningKey.fromValidBytes(sk).prefix.asTypedList;
    return await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: privateKey);
  }
}
