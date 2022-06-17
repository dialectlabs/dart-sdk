import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dialect_sdk/src/core/constants/constants.dart';
import 'package:dialect_sdk/src/internal/messaging/solana-messaging-errors.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter-wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter.interface.dart';
import 'package:dialect_sdk/src/wallet-adapter/node-dialect-wallet-adapter.dart';
import 'package:dialect_sdk/src/web3/api/borsh/borsh-ext.dart';
import 'package:dialect_sdk/src/web3/api/classes/dialect-account/dialect-account.dart';
import 'package:dialect_sdk/src/web3/api/classes/member/member.dart';
import 'package:dialect_sdk/src/web3/api/classes/message/message.dart' as msg;
import 'package:dialect_sdk/src/web3/api/classes/metadata/metadata.dart';
import 'package:dialect_sdk/src/web3/api/classes/raw-dialect/raw-dialect.dart';
import 'package:dialect_sdk/src/web3/api/dialect-instructions.dart';
import 'package:dialect_sdk/src/web3/api/text-serde/text-serde.dart';
import 'package:dialect_sdk/src/web3/utils/cyclic-byte-buffer/cyclic-byte-buffer.dart';
import 'package:dialect_sdk/src/web3/utils/encryption/ecdh-encryption.dart';
import 'package:dialect_sdk/src/web3/utils/index.dart';
import 'package:dialect_sdk/src/web3/utils/public-key/public-key.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

const ACCOUNT_DESCRIPTOR_SIZE = 8;

// TODO: Remove device token consts here
const DEVICE_TOKEN_LENGTH = 64;
const DEVICE_TOKEN_PADDING_LENGTH = DEVICE_TOKEN_PAYLOAD_LENGTH -
    DEVICE_TOKEN_LENGTH -
    ENCRYPTION_OVERHEAD_BYTES;

const DEVICE_TOKEN_PAYLOAD_LENGTH = 128;
const DIALECT_ACCOUNT_MEMBER0_OFFSET = ACCOUNT_DESCRIPTOR_SIZE;
const DIALECT_ACCOUNT_MEMBER1_OFFSET =
    DIALECT_ACCOUNT_MEMBER0_OFFSET + DIALECT_ACCOUNT_MEMBER_SIZE;
const DIALECT_ACCOUNT_MEMBER_SIZE = 34;

Future<Account?> accountInfoFetch(
    String url, RpcClient connection, String publicKeyStr) {
  final publicKey = Ed25519HDPublicKey.fromBase58(publicKeyStr);
  return accountInfoGet(connection, publicKey);
}

Future<Account?> accountInfoGet(
    RpcClient connection, Ed25519HDPublicKey publicKey) async {
  return await connection.getAccountInfo(publicKey.toBase58());
}

Future<DialectAccount> createDialect(
    {required RpcClient client,
    required ProgramAccount program,
    required KeypairWallet owner,
    required List<Member> members,
    encrypted = false,
    EncryptionProps? encryptionProps}) async {
  members
      .sort((a, b) => a.publicKey.toBase58().compareTo(b.publicKey.toBase58()));
  final programAddr = await getDialectProgramAddress(
      program, members.map((e) => e.publicKey).toList());
  final tx = await client.signAndSendTransaction(
      Message(instructions: [
        DialectInstructions.createDialect(
            owner.publicKey,
            members[0].publicKey,
            members[1].publicKey,
            programAddr.publicKey,
            programAddr.nonce,
            encrypted,
            members.map((e) => e.scopes).expand((element) => element).toList())
      ]),
      owner.signers);
  await waitForFinality(client: client, transactionStr: tx);
  sleep(Duration(seconds: 20));
  return await getDialectForMembers(client, program,
      members.map((e) => e.publicKey).toList(), encryptionProps);
}

Future<Metadata> createMetadata(
    {required RpcClient client,
    required ProgramAccount program,
    required KeypairWallet user}) async {
  final addressResult =
      await getMetadataProgramAddress(program, user.publicKey);
  final tx = await client.signAndSendTransaction(
      Message(instructions: [
        DialectInstructions.createMetadata(
            user.publicKey, addressResult.publicKey, addressResult.nonce)
      ]),
      user.signers);
  await waitForFinality(client: client, transactionStr: tx);
  return await getMetadata(
      client, program, KeypairWallet.fromKeypair(user.keyPair), null);
}

Future deleteDialect(RpcClient client, ProgramAccount program,
    DialectAccount dialectAccount, KeypairWallet owner) async {
  final addressResult = await getDialectProgramAddress(
      program, dialectAccount.dialect.members.map((e) => e.publicKey).toList());
  final tx = await client.signAndSendTransaction(
      Message(instructions: [
        DialectInstructions.closeDialect(
            owner.publicKey, addressResult.publicKey, addressResult.nonce)
      ]),
      owner.signers);
}

Future deleteMetadata(
    RpcClient client, ProgramAccount program, KeypairWallet user) async {
  final addressResult =
      await getMetadataProgramAddress(program, user.publicKey);
  await client.signAndSendTransaction(
      Message(instructions: [
        DialectInstructions.closeMetadata(
            user.publicKey, addressResult.publicKey, addressResult.nonce)
      ]),
      user.signers);
}

Future<List<DialectAccount>> findDialects(
    RpcClient client, ProgramAccount program, FindDialectQuery query) async {
  final List<ProgramDataFilter> memberFilters = query.userPk != null
      ? [
          ProgramDataFilter.memcmp(
              offset: DIALECT_ACCOUNT_MEMBER0_OFFSET,
              bytes: query.userPk!.bytes),
          ProgramDataFilter.memcmp(
              offset: DIALECT_ACCOUNT_MEMBER1_OFFSET,
              bytes: query.userPk!.bytes)
        ]
      : [];
  final results = await Future.wait(memberFilters.map((e) => client
      .getProgramAccounts(program.pubkey,
          encoding: Encoding.base64, filters: [e])));
  final dialects = results.expand((element) => element).map((e) {
    final rawDialect = parseBytesFromAccount(e.account, RawDialect.fromBorsh);
    return DialectAccount(
        dialect: parseRawDialect(rawDialect, null),
        publicKey: Ed25519HDPublicKey.fromBase58(e.pubkey));
  }).toList();
  dialects.sort((d1, d2) =>
      d2.dialect.lastMessageTimestamp -
      d1.dialect.lastMessageTimestamp); // descending
  return dialects;
}

Future<DialectAccount> getDialect(RpcClient client, ProgramAccount program,
    Ed25519HDPublicKey publicKey, EncryptionProps? encryptionProps) async {
  final account = await client.getAccountInfo(publicKey.toBase58(),
      encoding: Encoding.base64);
  if (account == null) {
    throw AccountNotFoundError();
  }
  final rawDialect = parseBytesFromAccount(account, RawDialect.fromBorsh);
  final dialect = parseRawDialect(rawDialect, encryptionProps);
  return DialectAccount(dialect: dialect, publicKey: publicKey);
}

Future<DialectAccount> getDialectForMembers(
    RpcClient client,
    ProgramAccount program,
    List<Ed25519HDPublicKey> members,
    EncryptionProps? encryptionProps) async {
  members.sort((a, b) => a.toBase58().compareTo(b.toBase58()));
  final pubKeyResult = await getDialectProgramAddress(program, members);
  return await getDialect(
      client, program, pubKeyResult.publicKey, encryptionProps);
}

Future<ProgramAddressResult> getDialectProgramAddress(
    ProgramAccount program, List<Ed25519HDPublicKey> members) {
  members.sort((a, b) => a.toBase58().compareTo(b.toBase58()));
  var seeds = [utf8.encode('dialect'), ...members.map((e) => e.bytes)];
  return findProgramAddressWithNonce(
      seeds: seeds, programId: Ed25519HDPublicKey.fromBase58(program.pubkey));
}

Future<List<DialectAccount>> getDialects(
    RpcClient client,
    ProgramAccount program,
    KeypairWallet user,
    EncryptionProps? encryptionProps) async {
  final metadata = await getMetadata(client, program, user, null);
  final enbaledSubscriptions =
      metadata.subscriptions.where((element) => element.enabled);
  final dialects = await Future.wait(enbaledSubscriptions
      .map((e) => getDialect(client, program, e.pubKey, encryptionProps)));
  dialects.sort((d1, d2) =>
      d2.dialect.lastMessageTimestamp - d1.dialect.lastMessageTimestamp);
  return dialects;
}

Future<Metadata> getMetadata(RpcClient client, ProgramAccount program,
    KeypairWallet user, KeypairWallet? otherParty) async {
  var shouldDecrypt = false;
  var userIsKeypair = user.isKeypair;
  var otherPartyIsKeypair = otherParty != null && otherParty.isKeypair;

  if (otherParty != null && (userIsKeypair || otherPartyIsKeypair)) {
    shouldDecrypt = true;
  }
  final addressResult = await getMetadataProgramAddress(
      program,
      userIsKeypair
          ? (await user.keyPair!.extractPublicKey())
          : user.publicKey);
  final account = await client.getAccountInfo(
      addressResult.publicKey.toBase58(),
      encoding: Encoding.base64);
  final metadata = parseBytesFromAccount(account, Metadata.fromBorsh);
  return Metadata(
      subscriptions: metadata.subscriptions
          .where((element) => element.pubKey != DEFAULT_PUBKEY)
          .toList());
}

Future<ProgramAddressResult> getMetadataProgramAddress(
    ProgramAccount program, Ed25519HDPublicKey user) {
  return findProgramAddressWithNonce(
      seeds: [utf8.encode('metadata'), utf8.encode(user.toBase58())],
      programId: Ed25519HDPublicKey.fromBase58(program.pubkey));
}

bool isDialectAdmin(DialectAccount dialect, Ed25519HDPublicKey user) {
  return dialect.dialect.members.any((element) =>
      element.publicKey.toBase58() == user.toBase58() && element.scopes[0]);
}

Future<Account?> ownerFetcher(
    String url, Wallet wallet, RpcClient connection) async {
  return accountInfoGet(connection, wallet.publicKey);
}

List<msg.Message> parseMessages(
    RawDialect rawDialect, EncryptionProps? encryptionProps) {
  final encrypted = rawDialect.encrypted;
  final rawMessagesBuffer = rawDialect.messages;
  final members = rawDialect.members;
  if (encrypted && encryptionProps == null) {
    return [];
  }
  final messagesBuffer = CyclicByteBuffer(
      rawMessagesBuffer.readOffset,
      rawMessagesBuffer.writeOffset,
      rawMessagesBuffer.itemsCount,
      Uint8List.fromList(rawMessagesBuffer.buffer));
  final textSerde = TextSerdeFactory.create(
      DialectAttributes(rawDialect.encrypted, rawDialect.members),
      encryptionProps);

  List<msg.Message> allMessages = messagesBuffer.items().map((item) {
    final byteBuffer = ByteData.view(item.buffer.buffer);
    final ownerMemberIndex = byteBuffer.getUint8(0);
    final messageOwner = members[ownerMemberIndex];
    final timestamp = byteBuffer.getUint32(0) * 1000;
    final serializedText =
        Uint8List.fromList(byteBuffer.buffer.asUint8List().sublist(5));
    final text = textSerde.deserialize(serializedText);
    return msg.Message(messageOwner.publicKey, text, timestamp);
  }).toList();
  return allMessages.reversed.toList();
}

Dialect parseRawDialect(
    RawDialect rawDialect, EncryptionProps? encryptionProps) {
  return Dialect(
      members: rawDialect.members,
      messages: parseMessages(rawDialect, encryptionProps),
      nextMessageIdx: rawDialect.messages.writeOffset,
      lastMessageTimestamp: rawDialect.lastMessageTimestamp * 1000,
      encrypted: rawDialect.encrypted);
}

Future<msg.Message> sendMessage(
    RpcClient client,
    ProgramAccount program,
    DialectAccount dialectAccount,
    KeypairWallet sender,
    String text,
    EncryptionProps? encryptionProps) async {
  final addressResult = await getDialectProgramAddress(
      program, dialectAccount.dialect.members.map((e) => e.publicKey).toList());
  final textSerde = TextSerdeFactory.create(
      DialectAttributes(
          dialectAccount.dialect.encrypted, dialectAccount.dialect.members),
      encryptionProps);
  final serializedText = textSerde.serialize(text);

  final tx = await client.signAndSendTransaction(
      Message(instructions: [
        DialectInstructions.sendMessage(sender.publicKey,
            addressResult.publicKey, addressResult.nonce, serializedText)
      ]),
      sender.signers);
  await waitForFinality(client: client, transactionStr: tx);

  // TODO: remove after testing
  sleep(Duration(seconds: 20));
  final d = await getDialect(
      client, program, addressResult.publicKey, encryptionProps);
  return d.dialect.messages[0];
}

class FindDialectQuery {
  Ed25519HDPublicKey? userPk;
  FindDialectQuery({required this.userPk});
}

class KeypairWallet {
  Ed25519HDKeyPair? keyPair;
  Ed25519HDPublicKey? wallet;

  KeypairWallet.fromKeypair(this.keyPair);

  KeypairWallet.fromWallet(this.wallet);

  bool get isKeypair => keyPair != null;

  bool get isWallet => wallet != null;
  Ed25519HDPublicKey get publicKey =>
      keyPair != null ? keyPair!.publicKey : wallet!;

  List<Ed25519HDKeyPair> get signers => keyPair != null ? [keyPair!] : [];
  static KeypairWallet fromWalletAdapter(DialectWalletAdapter adapter) {
    if (adapter is DialectWalletAdapterWrapper) {
      return fromWalletAdapterWrapper(adapter);
    } else if (adapter is NodeDialectWalletAdapter) {
      return KeypairWallet.fromKeypair(adapter.keypair);
    } else {
      return KeypairWallet.fromWallet(adapter.publicKey);
    }
  }

  static KeypairWallet fromWalletAdapterWrapper(
      DialectWalletAdapterWrapper wrapper) {
    return fromWalletAdapter(wrapper.delegate);
  }
}
