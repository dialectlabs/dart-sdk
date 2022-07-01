import 'package:dialect_sdk/src/address/addresses.interface.dart';
import 'package:dialect_sdk/src/dapp/dapp.interface.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_errors.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_dapp_addresses/data_service_wallet_dapp_addresses_dtos.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/wallet/wallet.interface.dart' as w;
import 'package:dialect_web3/dialect_web3.dart';
import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

DappAddress toDappAddress(DappAddressDto dto) {
  final wallet =
      w.Wallet(Ed25519HDPublicKey.fromBase58(dto.address.wallet.publicKey));
  final address = Address(dto.id, toAddressType(dto.address.type),
      dto.address.verified, dto.address.value, wallet);
  return DappAddress(dto.id, dto.enabled, dto.channelId, address);
}

class SolanaDappAddresses implements DappAddresses {
  final RpcClient _client;
  final ProgramAccount _program;

  SolanaDappAddresses(this._program, this._client);

  @override
  Future<List<DappAddress>> findAll() async {
    final dialectAccounts = await withErrorParsing(findDialects(
        _client,
        _program,
        FindDialectQuery(
            userPk: Ed25519HDPublicKey.fromBase58(_program.pubkey))));
    return dialectAccounts.map((e) {
      final dialectMember = _extractDialectMember(e);
      final wallet = w.Wallet(dialectMember.publicKey);
      return DappAddress(
          e.publicKey.toBase58(),
          true,
          null,
          Address(e.publicKey.toBase58(), AddressType.wallet, true,
              dialectMember.publicKey.toBase58(), wallet));
    }).toList();
  }

  Member _extractDialectMember(DialectAccount account) {
    final members = account.dialect.members
        .where((element) => element.publicKey.toBase58() != _program.pubkey);
    if (members.isEmpty) {
      throw IllegalStateError(title: "Shouldn't happen");
    }
    return members.first;
  }
}
