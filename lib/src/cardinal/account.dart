import 'package:borsh_annotation/borsh_annotation.dart';
import 'package:solana/dto.dart';

part 'account.g.dart';

class Basic1DataAccount {
  final List<int> discriminator;

  final int data;

  factory Basic1DataAccount.fromAccountData(AccountData accountData) {
    if (accountData is BinaryAccountData) {
      return Basic1DataAccount._fromBinary(accountData.data);
    } else {
      throw const FormatException('invalid account data found');
    }
  }

  const Basic1DataAccount._({
    required this.discriminator,
    required this.data,
  });

  factory Basic1DataAccount._fromBinary(
    List<int> bytes,
  ) {
    final accountData = _AccountData.fromBorsh(Uint8List.fromList(bytes));

    return Basic1DataAccount._(
      discriminator: bytes.sublist(0, 8),
      data: accountData.data.toInt(),
    );
  }
}

@BorshSerializable()
class _AccountData with _$_AccountData {
  factory _AccountData({
    @BU64() required BigInt data,
  }) = __AccountData;

  factory _AccountData.fromBorsh(Uint8List data) =>
      _$_AccountDataFromBorsh(data);

  _AccountData._();
}
