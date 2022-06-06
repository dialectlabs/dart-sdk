import 'package:dialect_sdk/src/dialect_sdk_base.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter.interface.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:solana/solana.dart';

class DialectWalletAdapterImpl implements DialectWalletAdapter {
  final DialectWalletAdapter delegate;
  DialectWalletAdapterImpl({required this.delegate});

  @override
  MessageEncryptionWalletAdapterPropsDiffieHellman? get diffieHellman =>
      (((pk) => _diffieHellman(pk)));

  @override
  set diffieHellman(
      MessageEncryptionWalletAdapterPropsDiffieHellman? _diffieHellman) {}

  @override
  Ed25519HDKeyPair get publicKey => delegate.publicKey;

  @override
  set publicKey(Ed25519HDKeyPair _publicKey) {}

  @override
  SignerWalletAdapterPropsSignAllTransactions? get signAllTransactions =>
      ((txs) => _signAllTransactions(txs));

  @override
  set signAllTransactions(
      SignerWalletAdapterPropsSignAllTransactions? _signAllTransactions) {}

  @override
  MessageSignerWalletAdapterPropsSignMessage? get signMessage =>
      ((msg) => _signMessage(msg));

  @override
  set signMessage(MessageSignerWalletAdapterPropsSignMessage? _signMessage) {}

  @override
  SignerWalletAdapterPropsSignTransaction? get signTransaction =>
      ((tx) => _signTransaction(tx));

  @override
  set signTransaction(
      SignerWalletAdapterPropsSignTransaction? _signTransaction) {}

  Future<DiffieHellmanResult> _diffieHellman(Uint8List publicKey) {
    if (delegate.diffieHellman == null) {
      throw UnsupportedOperationError(
        title: 'Signing not supported',
        msg:
            'Wallet does not support diffie hellman, please use wallet-adapter that supports diffieHellman() operation.',
      );
    }
    return delegate.diffieHellman!(publicKey);
  }

  Future<List<Transaction>> _signAllTransactions(
      List<Transaction> transactions) {
    if (delegate.signAllTransactions == null) {
      throw UnsupportedOperationError(
        title: 'Signing not supported',
        msg:
            'Wallet does not support signing all transactions, please use wallet-adapter that supports signAllTransactions() operation.',
      );
    }
    return delegate.signAllTransactions!(transactions);
  }

  Future<Uint8List> _signMessage(Uint8List message) {
    if (delegate.signMessage == null) {
      throw UnsupportedOperationError(
        title: 'Signing not supported',
        msg:
            'Wallet does not support signing messages, please use wallet-adapter that supports signMessage() operation.',
      );
    }
    return delegate.signMessage!(message);
  }

  Future<Transaction> _signTransaction(Transaction transaction) {
    if (delegate.signTransaction == null) {
      throw UnsupportedOperationError(
        title: 'Signing not supported',
        msg:
            'Wallet does not support signing, please use wallet-adapter that supports signTransaction() operation.',
      );
    }
    return delegate.signTransaction!(transaction);
  }
}
