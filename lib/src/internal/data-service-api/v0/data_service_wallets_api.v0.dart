import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/v0/data_service_wallets_dtos.v0.dart';
import 'package:dio/dio.dart';

class DataServiceWalletsApiClientV0 implements DataServiceWalletsApiV0 {
  final String baseUrl;
  final TokenProvider tokenProvider;

  final String v = "v0";
  final String suffix = "wallets";

  DataServiceWalletsApiClientV0(this.baseUrl, this.tokenProvider);

  @override
  Future<DappAddressDtoV0> createDappAddress(
      CreateAddressCommandV0 command, String dapp) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$v/$suffix/${token.body.sub}/dapps/$dapp/addresses",
            data: command.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DappAddressDtoV0.fromJson(json);
    }));
  }

  @override
  Future deleteDappAddress(DeleteAddressCommandV0 command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().delete(
        "$baseUrl/$v/$suffix/${token.body.sub}/addresses/${command.id}",
        options: Options(headers: createHeaders(token))));
  }

  @override
  Future<List<DappAddressDtoV0>> findAllDappAddresses(
      String dappPublicKey) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .get(
            "$baseUrl/$v/$suffix/${token.body.sub}/dapps/$dappPublicKey/addresses",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final List<dynamic> json = value.data;
      return json.map((e) => DappAddressDtoV0.fromJson(e)).toList();
    }));
  }
}

abstract class DataServiceWalletsApiV0 {
  Future<DappAddressDtoV0> createDappAddress(
      CreateAddressCommandV0 command, String dapp);
  Future deleteDappAddress(DeleteAddressCommandV0 command);
  Future<List<DappAddressDtoV0>> findAllDappAddresses(String dappPublicKey);
}
