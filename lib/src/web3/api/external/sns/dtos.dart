import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:dialect_sdk/src/web3/api/borsh/borsh-ext.dart';
import 'package:solana/solana.dart';

part 'dtos.g.dart';

@BorshSerializable()
class FavoriteDomain with _$FavoriteDomain {
  factory FavoriteDomain({
    @BU8() required int tag,
    @BPublicKey() required Ed25519HDPublicKey nameAccount,
  }) = _FavoriteDomain;

  @override
  factory FavoriteDomain.fromBorsh(Uint8List data) =>
      _$FavoriteDomainFromBorsh(data);

  FavoriteDomain._();
}

@BorshSerializable()
class NameRegistryState with _$NameRegistryState {
  static const int HEADER_LEN = 96;
  factory NameRegistryState(
      {@BPublicKey() required Ed25519HDPublicKey parentName,
      @BPublicKey() required Ed25519HDPublicKey owner,
      @BPublicKey() required Ed25519HDPublicKey stateClass,
      @BString() required String name}) = _NameRegistryState;

  @override
  factory NameRegistryState.fromBorsh(Uint8List data) =>
      _$NameRegistryStateFromBorsh(data);

  NameRegistryState._();
}
