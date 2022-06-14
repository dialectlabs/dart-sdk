import 'package:json_annotation/json_annotation.dart';
import 'package:solana/solana.dart';

class CreateDialectCommand {
  DialectMemberPartial me;
  DialectMember otherMember;
  bool encrypted;

  CreateDialectCommand(
      {required DialectMember myself,
      required this.otherMember,
      required this.encrypted})
      : me = DialectMemberPartial(scopes: myself.scopes);
}

// part 'messaging.interface.g.dart';

class DialectMember extends DialectMemberPartial {
  Ed25519HDPublicKey publicKey;

  DialectMember(
      {required this.publicKey, required List<DialectMemberScope> scopes})
      : super(scopes: scopes);
}

class DialectMemberPartial {
  List<DialectMemberScope> scopes;

  DialectMemberPartial({required this.scopes});
}

enum DialectMemberScope {
  @JsonValue(DialectMemberScopeDtoValues.admin)
  admin,
  @JsonValue(DialectMemberScopeDtoValues.write)
  write
}

class DialectMemberScopeDtoValues {
  static const String admin = "ADMIN";
  static const String write = "WRITE";
}

class FindDialectQuery {
  Ed25519HDPublicKey publicKey;

  FindDialectQuery({required this.publicKey});
}

class Message {
  String text;
  DateTime timestamp;
  DialectMember author;

  Message({required this.text, required this.timestamp, required this.author});
}

abstract class Messaging {
  Future<Thread> create(CreateDialectCommand command);
  Future<Thread?> find(FindDialectQuery query);
  Future<List<Thread>> findAll();
}

class SendMessageCommand {
  String text;

  SendMessageCommand({required this.text});
}

class Thread {
  Ed25519HDPublicKey publicKey;
  DialectMember me;
  DialectMember otherMember;
  bool encrypted;

  Thread(
      {required this.publicKey,
      required this.me,
      required this.otherMember,
      required this.encrypted});
}

extension DialectMemberScopeDtoExt on DialectMemberScope {
  String get value {
    switch (this) {
      case DialectMemberScope.write:
        return DialectMemberScopeDtoValues.write;
      case DialectMemberScope.admin:
        return DialectMemberScopeDtoValues.admin;
    }
  }

  static DialectMemberScope? find(String value) {
    for (var val in DialectMemberScope.values) {
      if (val.value == value) {
        return val;
      }
    }
    return null;
  }
}
