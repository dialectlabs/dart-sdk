import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

Future<ProgramAccount> createDialectProgram(
    RpcClient client, Ed25519HDPublicKey dialectProgramAddress) async {
  final account = await client.getAccountInfo(dialectProgramAddress.toBase58());

  return ProgramAccount(
      account: account!, pubkey: dialectProgramAddress.toBase58());
}
