import 'dart:typed_data';

import 'package:dialect_sdk/src/core/utils/ed2curve-utils.dart';
import 'package:dialect_sdk/src/core/utils/environment-utils.dart';
import 'package:dialect_sdk/src/core/utils/nacl-utils.dart';
import 'package:dialect_sdk/src/dialect_sdk_base.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter.interface.dart';
import 'package:solana/encoder.dart';
import 'package:solana/solana.dart' as solana;

class NodeDialectWalletAdapter extends DialectWalletAdapter {
  solana.Ed25519HDKeyPair keypair;

  NodeDialectWalletAdapter({required this.keypair})
      : super(
            publicKey: keypair.publicKey,
            signMessage: (message) {
              return NodeDialectWalletAdapter._signMessage(keypair, message);
            },
            signTransaction: (tx) {
              return NodeDialectWalletAdapter._signTransaction(keypair, tx);
            },
            signAllTransactions: (txs) {
              return NodeDialectWalletAdapter._signAllTransactions(
                  keypair, txs);
            },
            diffieHellman: () {
              return NodeDialectWalletAdapter._diffieHellman(
                  keypair, Uint8List.fromList(keypair.publicKey.bytes));
            });

  static Future<NodeDialectWalletAdapter> create(
      {solana.Ed25519HDKeyPair? keypair}) async {
    if (keypair != null) {
      // TODO: log
      return NodeDialectWalletAdapter(keypair: keypair);
    }
    if (Env.privateKey != null) {
      var privateKey = Env.privateKey!;
      solana.Ed25519HDKeyPair keypair =
          await solana.Ed25519HDKeyPair.fromPrivateKeyBytes(
              privateKey: Uint8List.fromList(privateKey.codeUnits));
      // TODO: log
      return NodeDialectWalletAdapter(keypair: keypair);
    }
    final generated = await solana.Ed25519HDKeyPair.random();
    // TODO: log
    return NodeDialectWalletAdapter(keypair: generated);
  }

  static Future<DiffieHellmanKeys> _diffieHellman(
      solana.Ed25519HDKeyPair keypair, Uint8List publicKey) async {
    final kp = Ed2CurveUtils.convertKeyPair(
        Uint8List.fromList(keypair.publicKey.bytes),
        Uint8List.fromList((await keypair.extract()).bytes));

    return DiffieHellmanKeys(publicKey: kp.publicKey, secretKey: kp.secretKey);
  }

  static Future<List<Transaction>> _signAllTransactions(
      solana.Ed25519HDKeyPair keypair, List<Transaction> transactions) async {
    return transactions;
  }

  static Future<Uint8List> _signMessage(
      solana.Ed25519HDKeyPair keypair, Uint8List message) async {
    var pk = await keypair.extractPublicKey();
    var sk = await keypair.extract();

    var signingKey = Uint8List.fromList(sk.bytes + pk.bytes);
    return NaClUtils.signDetached(message, signingKey);
  }

  static Future<Transaction> _signTransaction(
      solana.Ed25519HDKeyPair keypair, Transaction tx) async {
    var signed = await solana.signTransaction(
        tx.recentBlockhash, tx.message, tx.signers);
    var message = Message.decompile(
        CompiledMessage.fromSignedTransaction(signed.messageBytes));
    return Transaction(
        recentBlockhash: tx.recentBlockhash,
        message: message,
        signers: tx.signers);
  }
}
