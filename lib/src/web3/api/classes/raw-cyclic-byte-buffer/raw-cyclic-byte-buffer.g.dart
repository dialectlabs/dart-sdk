// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'raw-cyclic-byte-buffer.dart';

RawCyclicByteBuffer _$RawCyclicByteBufferFromBorsh(Uint8List data) {
  final reader = BinaryReader(data.buffer.asByteData());

  return const BRawCyclicByteBuffer().read(reader);
}

class BRawCyclicByteBuffer implements BType<RawCyclicByteBuffer> {
  const BRawCyclicByteBuffer();

  @override
  RawCyclicByteBuffer read(BinaryReader reader) {
    return RawCyclicByteBuffer(
      readOffset: const BU16().read(reader),
      writeOffset: const BU16().read(reader),
      itemsCount: const BU16().read(reader),
      buffer: const BFixedArray(8192, BU8()).read(reader),
    );
  }

  @override
  void write(BinaryWriter writer, RawCyclicByteBuffer value) {
    writer.writeStruct(value.toBorsh());
  }
}

// **************************************************************************
// BorshSerializableGenerator
// **************************************************************************

mixin _$RawCyclicByteBuffer {
  List<int> get buffer => throw UnimplementedError();
  int get itemsCount => throw UnimplementedError();
  int get readOffset => throw UnimplementedError();
  int get writeOffset => throw UnimplementedError();

  Uint8List toBorsh() {
    final writer = BinaryWriter();

    const BU16().write(writer, readOffset);
    const BU16().write(writer, writeOffset);
    const BU16().write(writer, itemsCount);
    const BFixedArray(8192, BU8()).write(writer, buffer);

    return writer.toArray();
  }
}

class _RawCyclicByteBuffer extends RawCyclicByteBuffer {
  @override
  final int readOffset;

  @override
  final int writeOffset;
  @override
  final int itemsCount;
  @override
  final List<int> buffer;
  _RawCyclicByteBuffer({
    required this.readOffset,
    required this.writeOffset,
    required this.itemsCount,
    required this.buffer,
  }) : super._();
}
