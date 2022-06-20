import 'dart:convert';

import 'package:dialect_sdk/src/web3/api/external/cardinal-twitter/constants.dart';
import 'package:dialect_sdk/src/web3/utils/public-key/public-key.dart';
import 'package:solana/solana.dart';

Future<ProgramAddressResult> findClaimRequestId(Ed25519HDPublicKey namespaceId,
    String entryName, Ed25519HDPublicKey requester) async {
  return findProgramAddressWithNonce(seeds: [
    utf8.encode(CLAIM_REQUEST_SEED),
    namespaceId.bytes,
    utf8.encode(entryName),
    requester.bytes
  ], programId: NAMESPACES_PROGRAM_ID);
}

Future<ProgramAddressResult> findDeprecatedReverseEntryId(
    Ed25519HDPublicKey publicKey) async {
  return findProgramAddressWithNonce(seeds: [
    utf8.encode(REVERSE_ENTRY_SEED),
    publicKey.bytes,
  ], programId: NAMESPACES_PROGRAM_ID);
}

Future<ProgramAddressResult> findGlobalContextId() async {
  return findProgramAddressWithNonce(seeds: [
    utf8.encode(GLOBAL_CONTEXT_SEED),
  ], programId: NAMESPACES_PROGRAM_ID);
}

Future<ProgramAddressResult> findNameEntryId(
    Ed25519HDPublicKey namespaceId, String entryName) async {
  return findProgramAddressWithNonce(seeds: [
    utf8.encode(ENTRY_SEED),
    namespaceId.bytes,
    utf8.encode(entryName)
  ], programId: NAMESPACES_PROGRAM_ID);
}

Future<ProgramAddressResult> findNamespaceId(String namespaceName) async {
  return findProgramAddressWithNonce(
      seeds: [utf8.encode(NAMESPACE_SEED), utf8.encode(namespaceName)],
      programId: NAMESPACES_PROGRAM_ID);
}

Future<ProgramAddressResult> findReverseEntryId(
    Ed25519HDPublicKey namespace, Ed25519HDPublicKey publicKey) async {
  return findProgramAddressWithNonce(seeds: [
    utf8.encode(REVERSE_ENTRY_SEED),
    namespace.bytes,
    publicKey.bytes,
  ], programId: NAMESPACES_PROGRAM_ID);
}
