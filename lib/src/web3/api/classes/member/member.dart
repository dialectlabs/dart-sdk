import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_sdk/src/web3/api/borsh-types/borsh-ext.dart';
import 'package:solana/solana.dart';

part 'member.g.dart';

@BorshSerializable()
class Member with _$Member {
  factory Member(
      {@BPublicKey() required Ed25519HDPublicKey publicKey,
      @BFixedArray(2, BBool()) required List<bool> scopes}) = _Member;

  factory Member.fromBorsh(Uint8List data) => _$MemberFromBorsh(data);

  Member._();
}
