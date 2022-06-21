import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data-service-api.dart'
    as api;
import 'package:dialect_sdk/src/internal/data-service-api/data-service-errors.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dtos/data-service-dtos.dart';
import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:dialect_sdk/src/internal/messaging/commons.dart';
import 'package:dialect_sdk/src/internal/messaging/messaging-errors.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/sdk/sdk.interface.dart';
import 'package:dialect_sdk/src/web3/api/text-serde/text-serde.dart';
import 'package:dialect_sdk/src/web3/utils/encryption/ecdh-encryption.dart';
import 'package:solana/solana.dart' as sol;

MemberDto? findMember(sol.Ed25519HDPublicKey memberPk, DialectDto dialect) {
  try {
    return dialect.members
        .map((element) => element)
        .firstWhere((element) => memberPk.toBase58() == element.publicKey);
  } catch (e) {
    return null;
  }
}

MemberDto? findOtherMember(
    sol.Ed25519HDPublicKey memberPk, DialectDto dialect) {
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
  final sol.Ed25519HDPublicKey me;
  final api.DataServiceDialectsApi dataServiceDialectsApi;
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
    final dialectAccountDto = await withErrorParsing(
        dataServiceDialectsApi.create(CreateDialectCommand(members: [
          PostMemberDto(
              publicKey: me.toBase58(),
              scopes: toDataServiceScopes(command.me.scopes)),
          PostMemberDto(
              publicKey: otherMember.publicKey.toBase58(),
              scopes: toDataServiceScopes(otherMember.scopes))
        ], encrypted: command.encrypted)),
        onResourceAlreadyExists: (e) => ThreadAlreadyExistsError());
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
                .map((e) => sol.Ed25519HDPublicKey.fromBase58(e.publicKey))
                .toList()),
        true);
  }

  @override
  Future<Thread?> find(FindThreadQuery query) async {
    final dialectAccountDto = await _findInternal(query);
    return dialectAccountDto != null
        ? _toDataServiceThread(dialectAccountDto)
        : null;
  }

  @override
  Future<List<Thread>> findAll() async {
    final dialectAccountDtos =
        await withErrorParsing(dataServiceDialectsApi.findAll());
    return Future.wait(dialectAccountDtos.map((e) => _toDataServiceThread(e)));
  }

  Future<DialectAccountDto?> _findByAddress(
      FindThreadByAddressQuery query) async {
    try {
      return await withErrorParsing(
          dataServiceDialectsApi.find(query.address.toBase58()));
    } catch (e) {
      if (e is ResourceNotFoundError) {
        return null;
      }
      rethrow;
    }
  }

  Future<DialectAccountDto?> _findByOtherMember(
      FindThreadByOtherMemberQuery query) async {
    final otherMember = requireSingleMember(query.otherMembers);
    final dialectAccountDtos = await withErrorParsing(
        dataServiceDialectsApi.findAll(
            query:
                api.FindDialectQuery(memberPublicKey: otherMember.toBase58())));
    if (dialectAccountDtos.length > 1) {
      throw IllegalStateError(
          title: "Found multiple dialects with same members");
    }
    return dialectAccountDtos[0];
  }

  Future<DialectAccountDto?> _findInternal(FindThreadQuery query) {
    if (query.isAddress()) {
      return _findByAddress(query as FindThreadByAddressQuery);
    }
    return _findByOtherMember(query as FindThreadByOtherMemberQuery);
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
        publicKey: sol.Ed25519HDPublicKey.fromBase58(otherMember.publicKey),
        scopes: fromDataServiceScopes(otherMember.scopes));
    return DataServiceThread(
        dataServiceDialectsApi: dataServiceDialectsApi,
        serde: serde.textSerde,
        me: ThreadMember(
            publicKey: sol.Ed25519HDPublicKey.fromBase58(meMember.publicKey),
            scopes: fromDataServiceScopes(meMember.scopes)),
        address: sol.Ed25519HDPublicKey.fromBase58(dialectAccountDto.publicKey),
        otherMembers: [otherThreadMember],
        otherMember: otherThreadMember,
        encryptionEnabled: dialectAccountDto.dialect.encrypted,
        canBeDecrypted: serde.decrypted,
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
            dialectAccountDto.dialect.lastMessageTimestamp.round()));
  }
}

class DataServiceThread extends Thread {
  final api.DataServiceDialectsApi dataServiceDialectsApi;
  final TextSerde serde;
  final ThreadMember otherMember;

  DataServiceThread(
      {required this.dataServiceDialectsApi,
      required this.serde,
      required ThreadMember me,
      required sol.Ed25519HDPublicKey address,
      required List<ThreadMember> otherMembers,
      required this.otherMember,
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
  @override
  Future delete() {
    return withErrorParsing(
        dataServiceDialectsApi.delete(publicKey.toBase58()));
  }

  @override
  Future<List<Message>> messages() async {
    final dialect = await withErrorParsing(
        dataServiceDialectsApi.find(publicKey.toBase58()));
    updatedAt = DateTime.fromMillisecondsSinceEpoch(
        dialect.dialect.lastMessageTimestamp);
    if (encryptionEnabled && !canBeDecrypted) {
      return [];
    }
    return dialect.dialect.messages
        .map((e) => Message(
            text: serde.deserialize(Uint8List.fromList(e.text)),
            timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp),
            author: e.owner == me.publicKey.toBase58() ? me : otherMember))
        .toList();
  }

  @override
  Future send(SendMessageCommand command) async {
    await withErrorParsing(dataServiceDialectsApi.sendMessage(
        publicKey.toBase58(),
        api.SendMessageCommand(serde.serialize(command.text))));
  }
}

class TextSerdeResult {
  TextSerde textSerde;
  bool decrypted;

  TextSerdeResult(this.textSerde, this.decrypted);
}
