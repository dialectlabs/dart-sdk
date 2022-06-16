import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter-wrapper.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

Future<ProgramAccount> createDialectProgram(
    DialectWalletAdapterWrapper walletAdapter,
    Ed25519HDPublicKey dialectProgramAddress,
    String rpcUrl) async {
  final client = RpcClient(rpcUrl);
  final account = await client.getAccountInfo(dialectProgramAddress.toBase58());
  if (account == null) {
    throw Exception(
        'Account could not be created with pubKey: ${dialectProgramAddress.toBase58()}');
  }
  return ProgramAccount(
      account: account, pubkey: dialectProgramAddress.toBase58());
}
