import 'package:dialect_sdk/src/dapp/dapp.interface.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/data_service_dapps_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_errors.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect_wallet_adapter_wrapper.dart';
import 'package:solana/solana.dart';

class DappImpl extends Dapp {
  DappImpl(Ed25519HDPublicKey publicKey, String name, bool verified,
      DappAddresses dappAddresses, String? description)
      : super(publicKey, name, description, verified, dappAddresses);
}

class DappsImpl implements Dapps {
  final DialectWalletAdapterWrapper _wallet;
  final DappAddresses _dappAddresses;
  final DataServiceDappsApi _dappsApi;

  DappsImpl(this._wallet, this._dappAddresses, this._dappsApi);

  @override
  Future<Dapp> create(CreateDappCommand command) async {
    final dappDto = await withErrorParsing(_dappsApi.create(
        CreateDappCommandDtoPartial(command.name,
            description: command.description)));
    return DappImpl(_wallet.publicKey, dappDto.name, dappDto.verified,
        _dappAddresses, dappDto.description);
  }

  @override
  Future<Dapp?> find() async {
    try {
      final dappDto = await withErrorParsing(_dappsApi.find());
      return _toDapp(dappDto);
    } catch (e) {
      final err = e as DataServiceApiClientError;
      if (err is ResourceNotFoundError) return null;
      rethrow;
    }
  }

  @override
  Future<List<DappBase>> findAll(FindDappQuery? query) async {
    final dappDtos = await withErrorParsing(
        _dappsApi.findAll(FindDappQueryDto(query?.verified)));
    return dappDtos
        .map((e) => DappBase(Ed25519HDPublicKey.fromBase58(e.publicKey), e.name,
            e.description, e.verified))
        .toList();
  }

  DappImpl _toDapp(DappDto dappDto) {
    return DappImpl(Ed25519HDPublicKey.fromBase58(dappDto.publicKey),
        dappDto.name, dappDto.verified, _dappAddresses, dappDto.description);
  }
}
