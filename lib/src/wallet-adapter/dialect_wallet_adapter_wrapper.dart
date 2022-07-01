import 'package:dialect_sdk/src/dialect_sdk_base.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption_keys_provider.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect_wallet_adapter.interface.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:solana/solana.dart';

class DialectWalletAdapterWrapper
    implements DialectWalletAdapter, CompatibilityProps {
  final DialectWalletAdapter delegate;
  DialectWalletAdapterWrapper({required this.delegate});

  @override
  MessageEncryptionWalletAdapterPropsDiffieHellman get diffieHellman =>
      _diffieHellman;

  @override
  set diffieHellman(
      MessageEncryptionWalletAdapterPropsDiffieHellman? _diffieHellman) {
    delegate.diffieHellman = _diffieHellman;
  }

  @override
  Ed25519HDPublicKey get publicKey => delegate.publicKey;

  @override
  set publicKey(Ed25519HDPublicKey _publicKey) {
    delegate.publicKey = _publicKey;
  }

  @override
  SignerWalletAdapterPropsSignAllTransactions get signAllTransactions =>
      _signAllTransactions;

  @override
  set signAllTransactions(
      SignerWalletAdapterPropsSignAllTransactions? _signAllTransactions) {
    delegate.signAllTransactions = _signAllTransactions;
  }

  @override
  MessageSignerWalletAdapterPropsSignMessage get signMessage => _signMessage;

  @override
  set signMessage(MessageSignerWalletAdapterPropsSignMessage? _signMessage) {
    delegate.signMessage = _signMessage;
  }

  @override
  SignerWalletAdapterPropsSignTransaction get signTransaction =>
      _signTransaction;

  @override
  set signTransaction(
      SignerWalletAdapterPropsSignTransaction? _signTransaction) {
    delegate.signTransaction = _signTransaction;
  }

  @override
  bool canEncrypt() {
    return delegate.diffieHellman != null;
  }

  @override
  bool canUseDialectCloud() {
    return delegate.signMessage != null;
  }

  @override
  bool canUseSolana() {
    return delegate.signTransaction != null &&
        delegate.signAllTransactions != null;
  }

  Future<DiffieHellmanKeys> _diffieHellman() async {
    if (delegate.diffieHellman == null) {
      throw UnsupportedOperationError(
        title: 'Signing not supported',
        msg:
            'Wallet does not support diffie hellman, please use wallet-adapter that supports diffieHellman() operation.',
      );
    }
    return delegate.diffieHellman!();
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

  static DialectWalletAdapterWrapper create(DialectWalletAdapter adapter) {
    return DialectWalletAdapterWrapper(delegate: adapter);
  }
}
