import 'dart:convert';

import 'package:dialect_sdk/src/core/constants/constants.dart';
import 'package:dialect_sdk/src/web3/api/classes/member/member.dart';
import 'package:dialect_sdk/src/web3/api/index.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  group('web3 tests', () {
    late RpcClient client;
    late ProgramAccount program;
    late List<Ed25519HDKeyPair> users;
    late Wallet wallet;
    setUp(() async {
      // const networkUrl = "https://api.mainnet-beta.solana.com";
      // const networkUrl = "https://api.devnet.solana.com";
      const networkUrl = "http://localhost:8899";
      client = RpcClient(networkUrl);
      final account =
          await client.getAccountInfo(DIALECT_PROGRAM_ID.toBase58());
      program = ProgramAccount(
          account: account!, pubkey: DIALECT_PROGRAM_ID.toBase58());
      users = [
        await Ed25519HDKeyPair.random(),
        await Ed25519HDKeyPair.random()
      ];
      wallet = await Wallet.fromPrivateKeyBytes(
          privateKey: (await users[0].extract()).bytes);
    });

    test('retrieve account data on local', () async {
      try {
        fundUsers(client: client, keypairs: users);
        final user1 = users[0];
        final user2 = users[1];
        final dialectMembers = [
          Member(publicKey: user1.publicKey, scopes: [true, true]),
          Member(publicKey: user2.publicKey, scopes: [false, true])
        ];
        final user1Dialect = await createDialect(
            client: client,
            program: program,
            owner: KeypairWallet.fromKeypair(user1),
            members: dialectMembers);
        await sendMessage(client, program, user1Dialect,
            KeypairWallet.fromKeypair(user1), "Hello dialect!", null);
        final dialect = await getDialectForMembers(client, program,
            dialectMembers.map((e) => e.publicKey).toList(), null);
        print(JsonEncoder().convert(dialect.dialect.messages));
      } catch (e) {
        print("error $e");
      }
    });
  });
}

const LAMPORTS_PER_SOL = 1000000000;

Future fundUsers({
  required RpcClient client,
  required List<Ed25519HDKeyPair> keypairs,
  int amount = 10 * LAMPORTS_PER_SOL,
}) async {
  await Future.wait(
    keypairs.map((keypair) async {
      final fromAirdropSignature = await client.requestAirdrop(
        keypair.publicKey.toBase58(),
        amount,
      );
      final statuses =
          await client.getSignatureStatuses([fromAirdropSignature]);
      print("statuses: $statuses");
    }),
  );
}
