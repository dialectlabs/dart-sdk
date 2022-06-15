import 'dart:ffi';
import 'dart:typed_data';

import 'package:hex/hex.dart';

// size reference:
class AnchorClass {
  AnchorClass();

  int get size => types.map((e) => e.size).reduce((v, e) => v + e);

  List<AnchorType> get types => [];

  List<AnchorTypeValue> deserialize(Uint8List buffer) {
    var hexBuf = HEX.encode(buffer);
    hexBuf = hexBuf.substring(16);

    List<AnchorTypeValue> values = [];
    for (var type in types) {
      final result = type.deserialize(hexBuf);
      hexBuf = result.buffer;
      values.add(result.value);
    }
    return values;
  }

  Uint8List serialize() {
    Uint8List buffer = Uint8List(size);
    for (var type in types) {
      final result = type.serialize();
      buffer = Uint8List.fromList(buffer + result);
    }
    return buffer;
  }
}

class AnchorType<T> {
  AnchorType();
  int get size {
    throw UnimplementedError();
  }

  AnchorTypeResult<T> deserialize(String buffer) {
    throw UnimplementedError();
  }

  ByteData getByteData(String buffer) {
    return ByteData.view(
        Uint8List.fromList(HEX.decode(buffer.substring(0, size))).buffer);
  }

  Uint8List serialize() {
    throw UnimplementedError();
  }
}

class AnchorTypeResult<T> extends AnchorTypeValue<T> {
  String buffer;
  AnchorTypeResult(T value, this.buffer) : super(value);
}

class AnchorTypeValue<T> {
  T value;
  AnchorTypeValue(this.value);
}

class BOOL extends AnchorType<bool> {
  @override
  int get size => 4;

  @override
  AnchorTypeResult<bool> deserialize(String buffer) {
    // TODO: implement deserialize
    throw UnimplementedError();
  }

  @override
  Uint8List serialize() {
    // TODO: implement serialize
    throw UnimplementedError();
  }
}

class TestAnchor extends AnchorClass {
  BOOL encrypted;
  U8 someSize;

  TestAnchor({required this.encrypted, required this.someSize});

  @override
  List<AnchorType> get types => [encrypted, someSize];
}

class U8 extends AnchorType<Uint8> {
  @override
  int get size => 2;

  @override
  AnchorTypeResult<Uint8> deserialize(String buffer) {
    var value = getByteData(buffer).getUint8(0);
    return AnchorTypeResult(value as Uint8, buffer);
  }

  @override
  Uint8List serialize() {
    // TODO: implement serialize
    throw UnimplementedError();
  }
}
