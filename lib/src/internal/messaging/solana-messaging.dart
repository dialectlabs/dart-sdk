import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
import 'package:dialect_sdk/src/internal/messaging/commons.dart';
import 'package:dialect_sdk/src/internal/messaging/messaging-errors.dart';
import 'package:dialect_sdk/src/internal/messaging/solana-messaging-errors.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart' as msg;
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/sdk/sdk.interface.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter-wrapper.dart';
import 'package:dialect_sdk/src/web3/api/classes/dialect-account/dialect-account.dart';
import 'package:dialect_sdk/src/web3/api/classes/member/member.dart';
import 'package:dialect_sdk/src/web3/api/index.dart';
import 'package:dialect_sdk/src/web3/api/text-serde/text-serde.dart';
import 'package:dialect_sdk/src/web3/utils/encryption/ecdh-encryption.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

Member? findMember(Ed25519HDPublicKey memberPk, Dialect dialect) {
  var members = dialect.members
      .where((element) => element.publicKey == memberPk.toBase58());
  return members.isEmpty ? null : members.first;
}

Member? findOtherMember(Ed25519HDPublicKey memberPk, Dialect dialect) {
  var members = dialect.members
      .where((element) => element.publicKey != memberPk.toBase58());
  return members.isEmpty ? null : members.first;
}

List<msg.ThreadMemberScope> fromProtocolScopes(bool scope1, bool scope2) {
  return [
    ...(scope1 ? [msg.ThreadMemberScope.admin] : []),
    ...(scope2 ? [msg.ThreadMemberScope.write] : [])
  ];
}

Future<EncryptionProps?> getEncryptionProps(
    Ed25519HDPublicKey me, DiffieHellmanKeys? encryptionKeys) async {
  return encryptionKeys != null
      ? EncryptionProps(me,
          Curve25519KeyPair(encryptionKeys.publicKey, encryptionKeys.publicKey))
      : null;
}

List<bool> toProtocolScopes(List<msg.ThreadMemberScope> scopes) {
  return [
    scopes.any((element) => element == msg.ThreadMemberScope.admin),
    scopes.any((element) => element == msg.ThreadMemberScope.write)
  ];
}

Future<SolanaThread> toSolanaThread(
    RpcClient client,
    DialectAccount dialectAccount,
    DialectWalletAdapterWrapper walletAdapter,
    EncryptionKeysProvider encryptionKeysProvider,
    ProgramAccount program) async {
  final dialect = dialectAccount.dialect;
  final publicKey = dialectAccount.publicKey;
  final meMember = findMember(walletAdapter.publicKey, dialectAccount.dialect);
  final otherMember =
      findOtherMember(walletAdapter.publicKey, dialectAccount.dialect);
  if (meMember == null || otherMember == null) {
    throw IllegalStateError(
        title:
            "Cannot resolve members from the given list ${dialect.members.map((e) => e.publicKey)} and wallet public key ${walletAdapter.publicKey.toBase58()}");
  }
  final canBeDecrypted = dialect.encrypted
      ? (await encryptionKeysProvider.getFailSafe()) != null
      : true;
  final otherThreadMember = msg.ThreadMember(
      publicKey: otherMember.publicKey,
      scopes: fromProtocolScopes(
          otherMember.scopes.first, otherMember.scopes.last));
  return SolanaThread(
    updatedAt: DateTime.now(),
    client: client,
    dialectAccount: dialectAccount,
    me: msg.ThreadMember(
        scopes: fromProtocolScopes(meMember.scopes.first, meMember.scopes.last),
        publicKey: meMember.publicKey),
    otherMember: otherThreadMember,
    address: publicKey,
    otherMembers: [otherThreadMember],
    encryptionEnabled: dialect.encrypted,
    canBeDecrypted: canBeDecrypted,
    program: program,
    walletAdapter: walletAdapter,
    encryptionKeysProvider: encryptionKeysProvider,
  );
}

class SolanaMessaging implements msg.Messaging {
  final DialectWalletAdapterWrapper walletAdapter;
  final ProgramAccount program;
  final EncryptionKeysProvider encryptionKeysProvider;
  final RpcClient client;

  SolanaMessaging(
      {required this.walletAdapter,
      required this.client,
      required this.program,
      required this.encryptionKeysProvider});

  @override
  Future<msg.Thread> create(msg.CreateThreadCommand command) async {
    final dialectAccount = await createInternal(command);
    return toSolanaThread(
        client, dialectAccount, walletAdapter, encryptionKeysProvider, program);
  }

  createInternal(msg.CreateThreadCommand command) async {
    final otherMember = requireSingleMember(command.otherMembers);
    try {
      return await withErrorParsing(createDialect(
          client: client,
          program: program,
          owner: KeypairWallet.fromWallet(walletAdapter.publicKey),
          members: [
            Member(
                publicKey: walletAdapter.publicKey,
                scopes: toProtocolScopes(command.me.scopes)),
            Member(
                publicKey: otherMember.publicKey,
                scopes: toProtocolScopes(otherMember.scopes))
          ],
          encrypted: command.encrypted,
          encryptionProps: await _getEncryptionProps(command)));
    } catch (e) {
      final err = e as SolanaError;
      if (err.type == 'AccountAlreadyExistsError') {
        throw ThreadAlreadyExistsError();
      }
      rethrow;
    }
  }

  @override
  Future<msg.Thread?> find(msg.FindThreadQuery query) async {
    final dialectAccount = await findInternal(query);
    return dialectAccount != null
        ? toSolanaThread(client, dialectAccount, walletAdapter,
            encryptionKeysProvider, program)
        : null;
  }

  @override
  Future<List<msg.Thread>> findAll() async {
    final dialects = await findDialects(
        client, program, FindDialectQuery(userPk: walletAdapter.publicKey));
    return Future.wait(dialects.map((e) => toSolanaThread(
        client, e, walletAdapter, encryptionKeysProvider, program)));
  }

  Future<DialectAccount?> findInternal(msg.FindThreadQuery query) async {
    final encryptionKeys = await encryptionKeysProvider.getFailSafe();
    final encryptionProps =
        await getEncryptionProps(walletAdapter.publicKey, encryptionKeys);
    try {
      if (query is msg.FindThreadByAddressQuery) {
        return _findByAddress(query, encryptionProps);
      }
      return _findByOtherMember(
          query as msg.FindThreadByOtherMemberQuery, encryptionProps);
    } catch (e) {
      final err = e as SolanaError;
      if (err.type == "AccountNotFoundError") {
        return null;
      }
      rethrow;
    }
  }

  _findByAddress(msg.FindThreadByAddressQuery query,
      EncryptionProps? encryptionProps) async {
    return withErrorParsing(
        getDialect(client, program, query.address, encryptionProps));
  }

  _findByOtherMember(msg.FindThreadByOtherMemberQuery query,
      EncryptionProps? encryptionProps) async {
    final otherMember = requireSingleMember(query.otherMembers);
    return withErrorParsing(getDialectForMembers(client, program,
        [walletAdapter.publicKey, otherMember], encryptionProps));
  }

  Future<EncryptionProps?> _getEncryptionProps(
      msg.CreateThreadCommand command) async {
    final encryptionKeys =
        command.encrypted ? await encryptionKeysProvider.getFailFast() : null;
    return getEncryptionProps(walletAdapter.publicKey, encryptionKeys);
  }

  static SolanaMessaging createSM(DialectWalletAdapterWrapper walletAdapter,
      ProgramAccount program, RpcClient client) {
    final encryptionKeysProvider = DialectWalletAdapterEncryptionKeysProvider(
        dialectWalletAdapter: walletAdapter);
    return SolanaMessaging(
        walletAdapter: walletAdapter,
        program: program,
        client: client,
        encryptionKeysProvider: encryptionKeysProvider);
  }
}

class SolanaThread extends msg.Thread {
  DialectAccount dialectAccount;
  final EncryptionKeysProvider encryptionKeysProvider;
  final DialectWalletAdapterWrapper walletAdapter;
  final ProgramAccount program;
  final msg.ThreadMember otherMember;
  final RpcClient client;
  SolanaThread(
      {required this.dialectAccount,
      required this.client,
      required this.encryptionKeysProvider,
      required this.walletAdapter,
      required this.program,
      required msg.ThreadMember me,
      required Ed25519HDPublicKey address,
      required List<msg.ThreadMember> otherMembers,
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
            backend: Backend.solana,
            updatedAt: updatedAt);

  @override
  DateTime get updatedAt {
    return DateTime.fromMillisecondsSinceEpoch(
        dialectAccount.dialect.lastMessageTimestamp.round());
  }

  Future delete() async {
    await deleteDialect(client, program, dialectAccount,
        KeypairWallet.fromWallet(walletAdapter.publicKey));
  }

  Future<List<msg.Message>> messages() async {
    final encryptionKeys = await encryptionKeysProvider.getFailSafe();
    final encryptionProps =
        await getEncryptionProps(me.publicKey, encryptionKeys);
    dialectAccount = await getDialect(
        client, program, dialectAccount.publicKey, encryptionProps);
    return dialectAccount.dialect.messages
        .map((e) => msg.Message(
            author: e.owner == me.publicKey ? me : otherMember,
            text: e.text,
            timestamp: DateTime.fromMillisecondsSinceEpoch(e.timestamp)))
        .toList();
  }

  Future send(msg.SendMessageCommand command) async {
    final encryptionKeys = await encryptionKeysProvider.getFailFast();
    final encryptionProps =
        await getEncryptionProps(me.publicKey, encryptionKeys);
    await sendMessage(
        client,
        program,
        dialectAccount,
        KeypairWallet.fromWallet(walletAdapter.publicKey),
        command.text,
        encryptionProps);
  }
}
