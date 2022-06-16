import 'package:pinenacl/ed25519.dart';
import 'package:pinenacl/tweetnacl.dart';
import 'package:solana/solana.dart';

class NaClUtils {
  static const cryptoSecretboxBOXZEROBYTES = 32;
  static const cryptoBoxBEFORENMBYTES = 32;
  static const cryptoSecretboxKEYBYTES = 32;
  static const cryptoSecretboxNONCEBYTES = 24;

  static Uint8List box(Uint8List box, Uint8List nonce, Uint8List publicKey,
      Uint8List secretKey) {
    var k = boxBefore(publicKey, secretKey);
    return secretBox(box, nonce, k);
  }

  static Uint8List boxBefore(Uint8List publicKey, Uint8List secretKey) {
    var k = Uint8List(cryptoBoxBEFORENMBYTES);
    TweetNaCl.crypto_box_beforenm(k, publicKey, secretKey);
    return k;
  }

  static Uint8List? boxOpen(Uint8List box, Uint8List nonce, Uint8List publicKey,
      Uint8List secretKey) {
    var k = boxBefore(publicKey, secretKey);
    return secretBoxOpen(box, nonce, k);
  }

  static checkLengths(Uint8List k, Uint8List n) {
    if (k.length != cryptoSecretboxKEYBYTES) {
      throw Exception('bad key size');
    }
    if (n.length != cryptoSecretboxNONCEBYTES) {
      throw Exception('bad nonce size');
    }
  }

  static Uint8List secretBox(Uint8List box, Uint8List nonce, Uint8List k) {
    checkLengths(k, nonce);
    var c = Uint8List(cryptoSecretboxBOXZEROBYTES + box.length);
    var m = Uint8List(c.length);
    for (var i = 0; i < box.length; i++) {
      c[i + cryptoSecretboxBOXZEROBYTES] = box[i];
    }
    TweetNaCl.crypto_secretbox(m, c, c.length, nonce, k);
    return m.sublist(cryptoSecretboxBOXZEROBYTES);
  }

  static Uint8List? secretBoxOpen(Uint8List box, Uint8List nonce, Uint8List k) {
    checkLengths(k, nonce);
    var c = Uint8List(cryptoSecretboxBOXZEROBYTES + box.length);
    var m = Uint8List(c.length);
    for (var i = 0; i < box.length; i++) {
      c[i + cryptoSecretboxBOXZEROBYTES] = box[i];
    }
    if (c.length < 32) return null;
    try {
      TweetNaCl.crypto_secretbox_open(m, c, c.length, nonce, k);
      return m.sublist(cryptoSecretboxBOXZEROBYTES);
    } catch (e) {
      return null;
    }
  }

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
