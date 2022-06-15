// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw-dialect.dart';

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$RawDialect {
  bool get encrypted => throw UnimplementedError();
  int get lastMessageTimestamp => throw UnimplementedError();
  RawCyclicByteBuffer get messages => throw UnimplementedError();
  List<Member> get members => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BBool().write(writer, encrypted);
    const BU32().write(writer, lastMessageTimestamp);
    const BRawCyclicByteBuffer().write(writer, messages);
    const BFixedArray(2, BMember()).write(writer, members);

    return writer.toArray();
  }
}

class _RawDialect extends RawDialect {
  _RawDialect({
    required this.encrypted,
    required this.lastMessageTimestamp,
    required this.messages,
    required this.members,
  }) : super._();

  final bool encrypted;
  final int lastMessageTimestamp;
  final RawCyclicByteBuffer messages;
  final List<Member> members;
}

class BRawDialect implements BType<RawDialect> {
  const BRawDialect();

  @override
  void write(BinaryWriter writer, RawDialect value) {
    writer.writeStruct(value.toBorsh());
  }

  @override
  RawDialect read(BinaryReader reader) {
    return RawDialect(
      encrypted: const BBool().read(reader),
      lastMessageTimestamp: const BU32().read(reader),
      messages: const BRawCyclicByteBuffer().read(reader),
      members: const BFixedArray(2, BMember()).read(reader),
    );
  }
}

RawDialect _$RawDialectFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BRawDialect().read(reader);
}
