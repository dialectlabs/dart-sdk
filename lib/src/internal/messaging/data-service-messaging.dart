import 'package:dialect_sdk/src/internal/data-service-api/data-service-api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dtos/data-service-dtos.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:dialect_sdk/src/internal/messaging/commons.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/sdk/sdk.interface.dart';
import 'package:dialect_sdk/src/web3/api/text-serde/text-serde.dart';
import 'package:dialect_sdk/src/web3/utils/encryption/ecdh-encryption.dart';
import 'package:solana/solana.dart';

MemberDto? findMember(Ed25519HDPublicKey memberPk, DialectDto dialect) {
  try {
    return dialect.members
        .map((element) => element)
        .firstWhere((element) => memberPk.toBase58() == element.publicKey);
  } catch (e) {
    return null;
  }
}

MemberDto? findOtherMember(Ed25519HDPublicKey memberPk, DialectDto dialect) {
  try {
    return dialect.members
        .map((element) => element)
        .firstWhere((element) => memberPk.toBase58() != element.publicKey);
  } catch (e) {
    return null;
  }
}

List<ThreadMemberScope> fromDataServiceScopes(List<MemberScopeDto> scopes) {
  return scopes
      .map((it) => ThreadMemberScopeDtoExt.find(it.value))
      .where((it) => it != null)
      .map((it) => it!)
      .toList();
}

List<MemberScopeDto> toDataServiceScopes(List<ThreadMemberScope> scopes) {
  return scopes
      .map((it) => MemberScopeDtoExt.find(it.value))
      .where((it) => it != null)
      .map((it) => it!)
      .toList();
}

class DataServiceMessaging implements Messaging {
  final Ed25519HDPublicKey me;
  final DataServiceDialectsApi dataServiceDialectsApi;
  final EncryptionKeysProvider encryptionKeysProvider;
  DataServiceMessaging(
      {required this.me,
      required this.dataServiceDialectsApi,
      required this.encryptionKeysProvider});

  Future<DiffieHellmanKeys> checkEncryptionSupported() {
    return encryptionKeysProvider.getFailFast();
  }

  @override
  Future<Thread> create(CreateThreadCommand command) async {
    command.encrypted && ((await checkEncryptionSupported()) != null);
    final otherMember = requireSingleMember(command.otherMembers);
    final dialectAccountDto =
        await dataServiceDialectsApi.create(CreateDialectCommand(members: [
      PostMemberDto(
          publicKey: me.toBase58(),
          scopes: toDataServiceScopes(command.me.scopes)),
      PostMemberDto(
          publicKey: otherMember.publicKey.toBase58(),
          scopes: toDataServiceScopes(otherMember.scopes))
    ], encrypted: command.encrypted));
    return _toDataServiceThread(dialectAccountDto);
  }

  Future<TextSerdeResult> createTextSerde(DialectDto dialect) async {
    if (!dialect.encrypted) {
      return TextSerdeResult(UnencryptedTextSerde(), true);
    }
    final diffieHellmanKeyPair = await encryptionKeysProvider.getFailSafe();
    final encryptionProps = (diffieHellmanKeyPair != null)
        ? EncryptionProps(
            me,
            Curve25519KeyPair(
                diffieHellmanKeyPair.publicKey, diffieHellmanKeyPair.secretKey))
        : null;
    if (encryptionProps == null) {
      return TextSerdeResult(UnencryptedTextSerde(), false);
    }
    return TextSerdeResult(
        EncryptedTextSerde(
            encryptionProps: encryptionProps,
            members: dialect.members
                .map((e) => Ed25519HDPublicKey.fromBase58(e.publicKey))
                .toList()),
        true);
  }

  @override
  Future<Thread?> find(FindThreadQuery query) {
    // TODO: implement find
    throw UnimplementedError();
  }

  @override
  Future<List<Thread>> findAll() {
    // TODO: implement findAll
    throw UnimplementedError();
  }

  Future<DataServiceThread> _toDataServiceThread(
      DialectAccountDto dialectAccountDto) async {
    final meMember = findMember(me, dialectAccountDto.dialect);
    final otherMember = findOtherMember(me, dialectAccountDto.dialect);
    if (meMember == null || otherMember == null) {
      throw IllegalStateError(
          title:
              'Cannot resolve members from given list: ${dialectAccountDto.dialect.members.map((e) => e.publicKey)} and wallet public key ${me.toBase58()}');
    }
    final serde = await createTextSerde(dialectAccountDto.dialect);
    final otherThreadMember = ThreadMember(
        publicKey: Ed25519HDPublicKey.fromBase58(otherMember.publicKey),
        scopes: fromDataServiceScopes(otherMember.scopes));
    return DataServiceThread(
        dataServiceDialectsApi: dataServiceDialectsApi,
        serde: serde.textSerde,
        me: ThreadMember(
            publicKey: Ed25519HDPublicKey.fromBase58(meMember.publicKey),
            scopes: fromDataServiceScopes(meMember.scopes)),
        address: Ed25519HDPublicKey.fromBase58(dialectAccountDto.publicKey),
        otherMembers: [otherThreadMember],
        otherMember: otherThreadMember,
        encryptionEnabled: dialectAccountDto.dialect.encrypted,
        canBeDecrypted: serde.decrypted,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
            dialectAccountDto.dialect.lastMessageTimestamp.round()));
  }
}

class DataServiceThread extends Thread {
  final DataServiceDialectsApi dataServiceDialectsApi;
  final TextSerde serde;

  DataServiceThread(
      {required this.dataServiceDialectsApi,
      required this.serde,
      required ThreadMember me,
      required Ed25519HDPublicKey address,
      required List<ThreadMember> otherMembers,
      required ThreadMember otherMember,
      required bool encryptionEnabled,
      required bool canBeDecrypted,
      required DateTime updatedAt})
      : super(
            me: me,
            encryptionEnabled: encryptionEnabled,
            otherMembers: otherMembers,
            publicKey: address,
            canBeDecrypted: canBeDecrypted,
            backend: Backend.dialectCloud,
            updatedAt: updatedAt);
}

class TextSerdeResult {
  TextSerde textSerde;
  bool decrypted;

  TextSerdeResult(this.textSerde, this.decrypted);
}
