import 'dart:typed_data';

import 'package:dialect_sdk/src/dialect_sdk_base.dart';
import 'package:solana/solana.dart';

typedef MessageEncryptionWalletAdapterPropsDiffieHellman
    = Future<DiffieHellmanResult> Function(Uint8List)?;
typedef MessageSignerWalletAdapterPropsSignMessage = Future<Uint8List> Function(
    Uint8List)?;
typedef SignerWalletAdapterPropsSignAllTransactions = Future<List<Transaction>>
    Function(List<Transaction>)?;
typedef SignerWalletAdapterPropsSignTransaction = Future<Transaction> Function(
    Transaction)?;

abstract class DialectWalletAdapter {
  Ed25519HDKeyPair publicKey;
  SignerWalletAdapterPropsSignTransaction signTransaction;
  SignerWalletAdapterPropsSignAllTransactions signAllTransactions;
  MessageSignerWalletAdapterPropsSignMessage signMessage;
  MessageEncryptionWalletAdapterPropsDiffieHellman diffieHellman;

  DialectWalletAdapter(
      {required this.publicKey,
      this.signTransaction,
      this.signAllTransactions,
      this.signMessage,
      this.diffieHellman});
}

class DiffieHellmanResult {
  Uint8List publicKey;
  Uint8List secretKey;
  DiffieHellmanResult({required this.publicKey, required this.secretKey});
}
