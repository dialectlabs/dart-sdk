import 'dart:typed_data';

import 'package:dialect_sdk/src/dialect_sdk_base.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:solana/solana.dart';

typedef MessageEncryptionWalletAdapterPropsDiffieHellman
    = Future<DiffieHellmanKeys> Function()?;
typedef MessageSignerWalletAdapterPropsSignMessage = Future<Uint8List> Function(
    Uint8List)?;
typedef SignerWalletAdapterPropsSignAllTransactions = Future<List<Transaction>>
    Function(List<Transaction>)?;
typedef SignerWalletAdapterPropsSignTransaction = Future<Transaction> Function(
    Transaction)?;

abstract class CompatibilityProps {
  bool canEncrypt();
  bool canUseDialectCloud();
  bool canUseSolana();
}

abstract class DialectWalletAdapter {
  Ed25519HDPublicKey publicKey;
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
