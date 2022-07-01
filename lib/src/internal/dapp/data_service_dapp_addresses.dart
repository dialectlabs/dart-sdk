import 'package:dialect_sdk/src/address/addresses.interface.dart';
import 'package:dialect_sdk/src/dapp/dapp.interface.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/data_service_dapps_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_errors.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_dapp_addresses/data_service_wallet_dapp_addresses_dtos.dart';
import 'package:dialect_sdk/src/wallet/wallet.interface.dart' as w;
import 'package:solana/solana.dart';

DappAddress toDappAddress(DappAddressDto dto) {
  final wallet =
      w.Wallet(Ed25519HDPublicKey.fromBase58(dto.address.wallet.publicKey));
  final address = Address(dto.id, toAddressType(dto.address.type),
      dto.address.verified, dto.address.value, wallet);
  return DappAddress(dto.id, dto.enabled, dto.channelId, address);
}

class DataServiceDappAddresses implements DappAddresses {
  final DataServiceDappsApi _dataServiceDappsApi;

  DataServiceDappAddresses(this._dataServiceDappsApi);

  @override
  Future<List<DappAddress>> findAll() async {
    final dappAddressDtos =
        await withErrorParsing(_dataServiceDappsApi.findAllDappAddresses());
    return dappAddressDtos.map((e) => toDappAddress(e)).toList();
  }
}
