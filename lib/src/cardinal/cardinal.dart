import 'dart:convert';
import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:solana/base58.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

const ENTRY_SEED = "entry";
const NAMESPACE_SEED = "namespace";
const REVERSE_ENTRY_SEED = "reverse-entry";
final NAMESPACES_PROGRAM_ID = Ed25519HDPublicKey.fromBase58(
    "nameXpT2PwZ2iA6DTNYTotTmiMYusBCYqwBLN2QgF4w");

Future fetchAddressFromTwitterHandle(String handle) async {
  const NAMESPACE = 'twitter';
  try {
    await getNameEntry(NAMESPACE, handle);
  } catch (e) {
    print("inside error $e");
    return null;
  }
}

Future<String> getNameEntry(String namespaceName, String entryName) async {
  final client = RpcClient("https://api.mainnet-beta.solana.com");
  // final client = SolanaClient(
  //   rpcUrl: Uri.parse("https://api.mainnet-beta.solana.com"),
  //   websocketUrl: Uri.parse(""),
  // );
  print("handle: $entryName");
  var namespaceSeeds = [
    utf8.encode(NAMESPACE_SEED),
    utf8.encode(namespaceName)
  ];
  var namespacePda = await Ed25519HDPublicKey.findProgramAddress(
      seeds: namespaceSeeds, programId: NAMESPACES_PROGRAM_ID);
  print("namespace pda: $namespacePda");

  var entrySeeds = [
    utf8.encode(ENTRY_SEED),
    namespacePda.bytes,
    utf8.encode(entryName)
  ];

  var entryPda = await Ed25519HDPublicKey.findProgramAddress(
      seeds: entrySeeds, programId: NAMESPACES_PROGRAM_ID);
  var act = entryPda.toBase58();
  print("account pda: $act");
  var account = await client.getAccountInfo(act, encoding: Encoding.base64);

  var bumpLength = 2;
  var nameLength = 32;

  var binaryAccount = account?.data as BinaryAccountData;
  var hex = HEX.encode(binaryAccount.data);
  hex = hex.substring(16);

  var bump = ByteData.view(
          Uint8List.fromList(HEX.decode(hex.substring(0, bumpLength))).buffer)
      .getUint8(0);
  hex = hex.substring(bumpLength);
  print("bump: $bump");

  var name = base58encode(HEX.decode(hex.substring(0, nameLength)));
  hex = hex.substring(nameLength);
  print("name: $name");

  return "";
}

// List<dynamic> findProgramAddress(List<int> seeds, String programId) {
//   for (int i = 255; i > -1; i--) {
//     List<int> seed = [];
//     seed.addAll(seeds);
//     seed.addAll([i]);
//     seed.addAll(base58decode(programId));
//     seed.addAll("ProgramDerivedAddress".codeUnits);
//     Uint8List publicKeyBytes = Uint8List.fromList(sha256.convert(seed).bytes);
//     if (isPointOnEd25519Curve(publicKeyBytes)) {
//       return [base58encode(publicKeyBytes), i];
//     }
//   }
//   throw Exception("Unable to find a viable program address nonce");
// }

void getReverseEntry(Ed25519HDPublicKey pubKey) async {
  var seeds = [utf8.encode(REVERSE_ENTRY_SEED), pubKey.bytes];
  var pda = await Ed25519HDPublicKey.findProgramAddress(
      seeds: seeds, programId: NAMESPACES_PROGRAM_ID);
  var account =
      await RpcClient('http://localhost:8899').getAccountInfo(pda.toBase58());
  print('account ${account?.data.toString()}');
}

Future tryFetchSNSDomain() async {}

class ProgramAddressPayload {
  Ed25519HDPublicKey address;
  int nonce;
  ProgramAddressPayload(this.address, this.nonce);
}
