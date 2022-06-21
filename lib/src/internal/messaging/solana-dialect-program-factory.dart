import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

Future<ProgramAccount> createDialectProgram(
    RpcClient client, Ed25519HDPublicKey dialectProgramAddress) async {
  final account = await client.getAccountInfo(dialectProgramAddress.toBase58());

  return ProgramAccount(
      account: account!, pubkey: dialectProgramAddress.toBase58());
}

// Future establishDialectProgram(
//     RpcClient client, ProgramAccount program, KeypairWallet funder) async {
//   var tx = await client.signAndSendTransaction(
//       Message(instructions: [
//         SystemInstruction.createAccount(
//             fundingAccount: funder.publicKey,
//             newAccount: Ed25519HDPublicKey.fromBase58(program.pubkey),
//             lamports: 10000,
//             space: 10,
//             owner: funder.publicKey)
//       ]),
//       funder.signers);
//   await waitForFinality(client: client, transactionStr: tx);
// }
