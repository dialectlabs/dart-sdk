import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_sdk/src/web3/api/borsh-types/borsh-ext.dart';
import 'package:dialect_sdk/src/web3/api/classes/member/member.dart';
import 'package:dialect_sdk/src/web3/api/classes/raw-cyclic-byte-buffer/raw-cyclic-byte-buffer.dart';

part 'raw-dialect.g.dart';

@BorshSerializable()
class RawDialect with _$RawDialect {
  factory RawDialect(
      {@BBool() required bool encrypted,
      @BU32() required int lastMessageTimestamp,
      @BRawCyclicByteBuffer() required RawCyclicByteBuffer messages,
      @BFixedArray(2, BMember()) required List<Member> members}) = _RawDialect;

  factory RawDialect.fromBorsh(Uint8List data) => _$RawDialectFromBorsh(data);

  RawDialect._();
}
