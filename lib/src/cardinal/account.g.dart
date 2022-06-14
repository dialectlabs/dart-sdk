// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

_AccountData _$_AccountDataFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const B_AccountData().read(reader);
}

class B_AccountData implements BType<_AccountData> {
  const B_AccountData();

  @override
  _AccountData read(BinaryReader reader) {
    return _AccountData(
      data: const BU64().read(reader),
    );
  }

  @override
  void write(BinaryWriter writer, _AccountData value) {
    writer.writeStruct(value.toBorsh());
  }
}

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$_AccountData {
  BigInt get data => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU64().write(writer, data);

    return writer.toArray();
  }
}

class __AccountData extends _AccountData {
  @override
  final BigInt data;

  __AccountData({
    required this.data,
  }) : super._();
}
