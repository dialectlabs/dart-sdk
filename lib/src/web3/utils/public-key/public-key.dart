// modified from ed25519_hd_public_key.dart

import 'package:cryptography/cryptography.dart';
import 'package:solana/solana.dart';

const _maxBumpSeed = 255;
const _maxSeedLength = 32;
const _maxSeeds = 16;
final _magicWord = 'ProgramDerivedAddress'.codeUnits;
final _sha256 = Sha256();

Future<Ed25519HDPublicKey> createProgramAddress({
  required Iterable<int> seeds,
  required Ed25519HDPublicKey programId,
}) async {
  final seedBytes = seeds
      .followedBy(programId.bytes)
      .followedBy(_magicWord)
      .toList(growable: false);
  final data = await _computeHash(seedBytes);
  if (isPointOnEd25519Curve(data)) {
    throw const FormatException(
      'failed to create address with provided seeds',
    );
  } else {
    return Ed25519HDPublicKey(data);
  }
}

Future<ProgramAddressResult> findProgramAddressWithNonce({
  required Iterable<Iterable<int>> seeds,
  required Ed25519HDPublicKey programId,
}) async {
  if (seeds.length > _maxSeeds) {
    throw const FormatException('you can give me up to $_maxSeeds seeds');
  }
  final overflowingSeed = seeds.where((s) => s.length > _maxSeedLength);
  if (overflowingSeed.isNotEmpty) {
    throw const FormatException(
      'one or more of the seeds provided is too big',
    );
  }
  final flatSeeds = seeds.fold(<int>[], _flatten);
  int bumpSeed = _maxBumpSeed;
  while (bumpSeed >= 0) {
    try {
      final pubKey = await createProgramAddress(
        seeds: [...flatSeeds, bumpSeed],
        programId: programId,
      );
      return ProgramAddressResult(publicKey: pubKey, nonce: bumpSeed);
    } on FormatException {
      bumpSeed -= 1;
    }
  }

  throw const FormatException('cannot find program address with these seeds');
}

Future<List<int>> _computeHash(List<int> source) async {
  final hash = await _sha256.hash(source);

  return hash.bytes;
}

Iterable<int> _flatten(Iterable<int> concatenated, Iterable<int> current) =>
    concatenated.followedBy(current).toList();

class ProgramAddressResult {
  Ed25519HDPublicKey publicKey;
  int nonce;
  ProgramAddressResult({required this.publicKey, required this.nonce});
}
