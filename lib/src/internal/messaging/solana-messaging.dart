// import 'package:dialect_sdk/src/internal/data-service-api/dtos/data-service-dtos.dart';
// import 'package:dialect_sdk/src/internal/encryption/encryption-keys-provider.dart';
// import 'package:dialect_sdk/src/internal/messaging/commons.dart';
// import 'package:dialect_sdk/src/internal/messaging/messaging-errors.dart';
// import 'package:dialect_sdk/src/internal/messaging/solana-messaging-errors.dart';
// import 'package:dialect_sdk/src/messaging/messaging.interface.dart' as msg;
// import 'package:dialect_sdk/src/sdk/errors.dart';
// import 'package:dialect_sdk/src/sdk/sdk.interface.dart';
// import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter-wrapper.dart';
// import 'package:dialect_sdk/src/web3/api/index.dart';
// import 'package:dialect_sdk/src/web3/api/text-serde/text-serde.dart';
// import 'package:dialect_sdk/src/web3/utils/encryption/ecdh-encryption.dart';
// import 'package:solana/dto.dart';
// import 'package:solana/solana.dart';

// class SolanaMessaging implements msg.Messaging {
//   final DialectWalletAdapterWrapper walletAdapter;
//   final ProgramAccount program;
//   final EncryptionKeysProvider encryptionKeysProvider;

//   SolanaMessaging(
//       {required this.walletAdapter,
//       required this.program,
//       required this.encryptionKeysProvider});

//   @override
//   Future<msg.Thread> create(msg.CreateThreadCommand command) {
//     // TODO: implement create
//     throw UnimplementedError();
//   }

//   createInternal(msg.CreateThreadCommand command) async {
//     final otherMember = requireSingleMember(command.otherMembers);
//     try {
//       return await withErrorParsing(createDialect(program, walletAdapter, [],
//           command.encrypted, await _getEncryptionProps(command)));
//     } catch (e) {
//       final err = e as SolanaError;
//       if (err.type == 'AccountAlreadyExistsError') {
//         throw ThreadAlreadyExistsError();
//       }
//       rethrow;
//     }
//   }

//   @override
//   Future<msg.Thread?> find(msg.FindThreadQuery query) async {
//     final dialectAccount = findInternal(query);
//     return dialectAccount != null ? toSolanaThread() : null;
//   }

//   @override
//   Future<List<msg.Thread>> findAll() async {
//     final dialects = await findDialects(program);
//     return Future.wait(dialects.map((e) =>
//         toSolanaThread(e, walletAdapter, encryptionKeysProvider, program)));
//   }

//   Future<DialectAccountDto?> findInternal(msg.FindThreadQuery query) async {
//     final encryptionKeys = await encryptionKeysProvider.getFailSafe();
//     final encryptionProps =
//         await getEncryptionProps(walletAdapter.publicKey, encryptionKeys);
//     try {
//       if (query is msg.FindThreadByAddressQuery) {
//         return _findByAddress(query, encryptionProps);
//       }
//       return _findByOtherMember(
//           query as msg.FindThreadByOtherMemberQuery, encryptionProps);
//     } catch (e) {
//       final err = e as SolanaError;
//       if (err.type == "AccountNotFoundError") {
//         return null;
//       }
//       rethrow;
//     }
//   }

//   _findByAddress(
//       msg.FindThreadByAddressQuery query, EncryptionProps? encryptionProps) async {
//     return withErrorParsing(
//         getDialect(program, query.address, encryptionProps));
//   }

//   _findByOtherMember(msg.FindThreadByOtherMemberQuery query,
//       EncryptionProps? encryptionProps) async {
//     final otherMember = requireSingleMember(query.otherMembers);
//     return withErrorParsing(getDialectForMembers(
//         program, [walletAdapter.publicKey, otherMember], encryptionProps));
//   }

//   Future<EncryptionProps?> _getEncryptionProps(
//       msg.CreateThreadCommand command) async {
//     final encryptionKeys =
//         command.encrypted ? await encryptionKeysProvider.getFailFast() : null;
//     return getEncryptionProps(walletAdapter.publicKey, encryptionKeys);
//   }
// }

// class SolanaThread extends msg.Thread {
//   DialectAccountDto dialectAccount;
//   final EncryptionKeysProvider encryptionKeysProvider;
//   final DialectWalletAdapterWrapper walletAdapter;
//   final ProgramAccount program;
//   final msg.ThreadMember otherMember;
//   SolanaThread(
//       {required this.dialectAccount,
//       required this.encryptionKeysProvider,
//       required this.walletAdapter,
//       required this.program,
//       required msg.ThreadMember me,
//       required Ed25519HDPublicKey address,
//       required List<msg.ThreadMember> otherMembers,
//       required this.otherMember,
//       required bool encryptionEnabled,
//       required bool canBeDecrypted,
//       required DateTime updatedAt})
//       : super(
//             me: me,
//             encryptionEnabled: encryptionEnabled,
//             otherMembers: otherMembers,
//             publicKey: address,
//             canBeDecrypted: canBeDecrypted,
//             backend: Backend.Solana,
//             updatedAt: updatedAt);

//   Future delete() async {
//     await deleteDialect(program, dialectAccount, walletAdapter);
//   }

//   Future<List<msg.Message>> messages() async {
//     final encryptionKeys = await encryptionKeysProvider.getFailSafe();
//     final encryptionProps = getEncryptionProps(me.publicKey, encryptionKeys);
//     dialectAccount = await getDialect(program, dialectAccount.publicKey, encryptionProps);
//     return dialectAccount.dialect.messages.map((e) => msg.Message(author: it.owner == me.publicKey ? me : otherMember))
//   }

//   Future send(msg.SendMessageCommand command) async {
//     final encryptionKeys = encryptionKeysProvider.getFailFast();
//     final encryptionProps = getEncryptionProps(me.publicKey, encryptionKeys);
//     await sendMessage(
//       program,
//       dialectAccount,
//       walletAdapter,
//       command.text,
//       encryptionProps
//     );
//   }

//   @override
//   DateTime get updatedAt {
//     return DateTime.fromMillisecondsSinceEpoch(dialectAccount.dialect.lastMessageTimestamp.round());
//   }
// }

// List<msg.ThreadMemberScope> fromProtocolScopes(bool scope1, bool scope2) {
//   return [...(scope1 ? [msg.ThreadMemberScope.admin] : []), ...(scope2 ? [msg.ThreadMemberScope.write] : [])];
// }

// List<bool> toProtocolScopes(List<msg.ThreadMemberScope> scopes) {
//   return [scopes.any((element) => element == msg.ThreadMemberScope.admin), scopes.any((element) => element == msg.ThreadMemberScope.write)];
// }

// MemberDto? findMember(Ed25519HDPublicKey memberPk, DialectDto dialect) {
//   var members = dialect.members.where((element) => element.publicKey == memberPk.toBase58());
//   return members.isEmpty ? null : members.first;
// }

// MemberDto? findOtherMember(Ed25519HDPublicKey memberPk, DialectDto dialect) {
//   var members = dialect.members.where((element) => element.publicKey != memberPk.toBase58());
//   return members.isEmpty ? null : members.first;
// }

// Future<EncryptionProps?> getEncryptionProps(
//     Ed25519HDPublicKey me, DiffieHellmanKeys? encryptionKeys) async {
//   return encryptionKeys != null
//       ? EncryptionProps(
//           me,
//           Curve25519KeyPair(
//               encryptionKeys.publicKey, encryptionKeys.publicKey))
//       : null;
// }

// Future<SolanaThread> toSolanaThread(DialectAccountDto dialectAccount, DialectWalletAdapterWrapper walletAdapter, EncryptionKeysProvider encryptionKeysProvider, ProgramAccount program) async {
//   final dialect = dialectAccount.dialect;
//   final publicKey = dialectAccount.publicKey;
//   final meMember = findMember(walletAdapter.publicKey, dialectAccount.dialect);
//   final otherMember = findOtherMember(walletAdapter.publicKey, dialectAccount.dialect);
//   if (meMember == null || otherMember == null) {
//     throw IllegalStateError(title: "Cannot resolve members from the given list ${dialect.members.map((e) => e.publicKey)} and wallet public key ${walletAdapter.publicKey.toBase58()}");
//   }
//   final canBeDecrypted = dialect.encrypted ? (await encryptionKeysProvider.getFailSafe()) != null : true;
//   final otherThreadMember = msg.ThreadMember(publicKey: Ed25519HDPublicKey.fromBase58(otherMember.publicKey), scopes: fromProtocolScopes(scope1, scope2));
//   return SolanaThread(
//     updatedAt: DateTime.now(),
//     dialectAccount: dialectAccount,
//     me: msg.ThreadMember(scopes: fromProtocolScopes(meMember.scopes.first, meMember.scopes.last), publicKey: Ed25519HDPublicKey.fromBase58(meMember.publicKey)),
//     otherMember: otherThreadMember,
//     address: Ed25519HDPublicKey.fromBase58(publicKey),
//     otherMembers: [otherThreadMember],
//     encryptionEnabled: dialect.encrypted,
//     canBeDecrypted: canBeDecrypted,
//     program: program,
//     walletAdapter: walletAdapter,
//     encryptionKeysProvider: encryptionKeysProvider,
//   );
// }