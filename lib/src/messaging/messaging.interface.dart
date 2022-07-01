import 'package:dialect_sdk/src/core/converters/ed25519_public_key_converter.dart';
import 'package:dialect_sdk/src/sdk/sdk.interface.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:solana/solana.dart';

part 'messaging.interface.g.dart';

enum Backend {
  @JsonValue(BackendValueTypes.solana)
  solana,
  @JsonValue(BackendValueTypes.dialectCloud)
  dialectCloud
}

class BackendValueTypes {
  static const String solana = "SOLANA";
  static const String dialectCloud = "DIALECT_CLOUD";
}

@JsonSerializable(explicitToJson: true)
class CreateThreadCommand {
  @JsonKey(name: "me")
  final ThreadMemberPartial me;
  @JsonKey(name: "otherMembers")
  final List<ThreadMember> otherMembers;
  @JsonKey(name: "encrypted")
  final bool encrypted;
  @JsonKey(name: "backend")
  final Backend? backend;

  CreateThreadCommand(
      {required this.me,
      required this.otherMembers,
      required this.encrypted,
      this.backend});

  factory CreateThreadCommand.fromJson(Map<String, dynamic> json) =>
      _$CreateThreadCommandFromJson(json);
  Map<String, dynamic> toJson() => _$CreateThreadCommandToJson(this);
}

class FindThreadByIdQuery implements FindThreadQuery {
  ThreadId id;

  FindThreadByIdQuery({required this.id});

  @override
  bool isId() {
    return true;
  }

  @override
  bool isOtherMember() {
    return false;
  }
}

class FindThreadByOtherMemberQuery implements FindThreadQuery {
  List<Ed25519HDPublicKey> otherMembers;

  FindThreadByOtherMemberQuery({required this.otherMembers});

  @override
  bool isId() {
    return false;
  }

  @override
  bool isOtherMember() {
    return true;
  }
}

abstract class FindThreadQuery {
  bool isId();
  bool isOtherMember();
}

class Message {
  String text;
  DateTime timestamp;
  ThreadMember author;

  Message({required this.text, required this.timestamp, required this.author});

  @override
  int get hashCode => Object.hashAll([text, timestamp, author.publicKey]);

  @override
  bool operator ==(covariant DialectCloudEnvironment other) =>
      other.hashCode == hashCode;
}

abstract class Messaging {
  Future<Thread> create(CreateThreadCommand command);
  Future<Thread?> find(FindThreadQuery query);
  Future<List<Thread>> findAll();
}

@JsonSerializable()
class SendMessageCommand {
  @JsonKey(name: "text")
  final String text;

  SendMessageCommand({required this.text});

  factory SendMessageCommand.fromJson(Map<String, dynamic> json) =>
      _$SendMessageCommandFromJson(json);
  Map<String, dynamic> toJson() => _$SendMessageCommandToJson(this);
}

class Thread {
  Ed25519HDPublicKey publicKey;
  ThreadMember me;
  List<ThreadMember> otherMembers;
  bool encryptionEnabled;
  bool canBeDecrypted;
  Backend backend;
  DateTime updatedAt;

  Thread(
      {required this.publicKey,
      required this.me,
      required this.otherMembers,
      required this.encryptionEnabled,
      required this.canBeDecrypted,
      required this.backend,
      required this.updatedAt});

  Future delete() {
    throw UnimplementedError();
  }

  Future<List<Message>> messages() {
    throw UnimplementedError();
  }

  Future send(SendMessageCommand command) {
    throw UnimplementedError();
  }
}

class ThreadId {
  Ed25519HDPublicKey address;
  Backend? backend;
  ThreadId(this.address, this.backend);
}

@JsonSerializable(explicitToJson: true)
@Ed25519PublicKeyConverter()
class ThreadMember extends ThreadMemberPartial {
  @JsonKey(name: 'publicKey')
  Ed25519HDPublicKey publicKey;

  ThreadMember(
      {required this.publicKey, required List<ThreadMemberScope> scopes})
      : super(scopes: scopes);
  factory ThreadMember.fromJson(Map<String, dynamic> json) =>
      _$ThreadMemberFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ThreadMemberToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ThreadMemberPartial {
  @JsonKey(name: 'scopes')
  List<ThreadMemberScope> scopes;

  ThreadMemberPartial({required this.scopes});

  factory ThreadMemberPartial.fromJson(Map<String, dynamic> json) =>
      _$ThreadMemberPartialFromJson(json);
  Map<String, dynamic> toJson() => _$ThreadMemberPartialToJson(this);
}

enum ThreadMemberScope {
  @JsonValue(ThreadMemberScopeDtoValues.admin)
  admin,
  @JsonValue(ThreadMemberScopeDtoValues.write)
  write
}

class ThreadMemberScopeDtoValues {
  static const String admin = "ADMIN";
  static const String write = "WRITE";
}

extension ThreadMemberScopeDtoExt on ThreadMemberScope {
  String get value {
    switch (this) {
      case ThreadMemberScope.write:
        return ThreadMemberScopeDtoValues.write;
      case ThreadMemberScope.admin:
        return ThreadMemberScopeDtoValues.admin;
    }
  }

  static ThreadMemberScope? find(String value) {
    for (var val in ThreadMemberScope.values) {
      if (val.value == value) {
        return val;
      }
    }
    return null;
  }
}
