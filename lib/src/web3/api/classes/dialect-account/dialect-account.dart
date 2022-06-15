import 'package:dialect_sdk/src/web3/api/classes/member/member.dart';
import 'package:dialect_sdk/src/web3/api/classes/message/message.dart' as msg;
import 'package:solana/solana.dart';

// part 'dialect-account.g.dart';

class Dialect {
  List<Member> members;
  List<msg.Message> messages;
  int nextMessageIdx;
  int lastMessageTimestamp;
  bool encrypted;
  Dialect(
      {required this.members,
      required this.messages,
      required this.nextMessageIdx,
      required this.lastMessageTimestamp,
      required this.encrypted});
}

class DialectAccount {
  Dialect dialect;
  Ed25519HDPublicKey publicKey;
  DialectAccount({required this.dialect, required this.publicKey});
}
