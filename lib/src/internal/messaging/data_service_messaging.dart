import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_errors.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dialects/data_service_dialects_api.dart'
    as dcts;
import 'package:dialect_sdk/src/internal/encryption/encryption_keys_provider.dart';
import 'package:dialect_sdk/src/internal/messaging/commons.dart';
import 'package:dialect_sdk/src/internal/messaging/messaging_errors.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_web3/dialect_web3.dart' as web3;
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
  final dcts.DataServiceDialectsApi dataServiceDialectsApi;
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
      return TextSerdeResult(web3.UnencryptedTextSerde(), true);
    }
    final diffieHellmanKeyPair = await encryptionKeysProvider.getFailSafe();
    final encryptionProps = (diffieHellmanKeyPair != null)
        ? web3.EncryptionProps(
            me,
            web3.Curve25519KeyPair(
                diffieHellmanKeyPair.publicKey, diffieHellmanKeyPair.secretKey))
        : null;
    if (encryptionProps == null) {
      return TextSerdeResult(web3.UnencryptedTextSerde(), false);
    }
    return TextSerdeResult(
        web3.EncryptedTextSerde(
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

  Future<DialectAccountDto?> _findById(FindThreadByIdQuery query) async {
    try {
      return await withErrorParsing(
          dataServiceDialectsApi.find(query.id.address.toBase58()));
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
            query: dcts.FindDialectQuery(
                memberPublicKey: otherMember.toBase58())));
    if (dialectAccountDtos.length > 1) {
      throw IllegalStateError(
          title: "Found multiple dialects with same members");
    }
    return dialectAccountDtos.isEmpty ? null : dialectAccountDtos.first;
  }

  Future<DialectAccountDto?> _findInternal(FindThreadQuery query) {
    if (query.isId()) {
      return _findById(query as FindThreadByIdQuery);
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
  final dcts.DataServiceDialectsApi dataServiceDialectsApi;
  final web3.TextSerde serde;
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
    var messages = dialect.dialect.messages
        .map((e) => Message(
            text: serde.deserialize(Uint8List.fromList(e.text)),
            timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp),
            author: e.owner == me.publicKey.toBase58() ? me : otherMember))
        .toList();
    messages.sort(((a, b) =>
        a.timestamp.millisecondsSinceEpoch -
        b.timestamp.millisecondsSinceEpoch));
    return messages;
  }

  @override
  Future send(SendMessageCommand command) async {
    await withErrorParsing(dataServiceDialectsApi.sendMessage(
        publicKey.toBase58(),
        dcts.SendMessageCommand(serde.serialize(command.text))));
  }
}

class TextSerdeResult {
  web3.TextSerde textSerde;
  bool decrypted;

  TextSerdeResult(this.textSerde, this.decrypted);
}
