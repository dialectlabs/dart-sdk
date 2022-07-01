import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_dapp_addresses/data_service_wallet_dapp_addresses_dtos.dart';
import 'package:dio/dio.dart';

abstract class DataServiceWalletDappAddressesApi {
  Future<DappAddressDto> create(CreateDappAddressCommandDto command);
  Future delete(String dappAddressId);
  Future<DappAddressDto> find(String dappAddressId);
  Future<List<DappAddressDto>> findAll(FindDappAddressesQuery? query);
  Future<DappAddressDto> patch(
      String dappAddressId, PartialUpdateDappAddressCommandDto command);
}

class DataServiceWalletDappAddressesApiClient
    implements DataServiceWalletDappAddressesApi {
  final String baseUrl;
  final TokenProvider tokenProvider;

  final String prefix = "api";
  final String v = "v1";
  final String suffix = "wallets/me/dappAddresses";

  DataServiceWalletDappAddressesApiClient(this.baseUrl, this.tokenProvider);

  @override
  Future<DappAddressDto> create(CreateDappAddressCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$prefix/$v/$suffix",
            data: command.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DappAddressDto.fromJson(json);
    }));
  }

  @override
  Future delete(String dappAddressId) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().delete(
        "$baseUrl/$prefix/$v/$suffix/$dappAddressId",
        options: Options(headers: createHeaders(token))));
  }

  @override
  Future<DappAddressDto> find(String dappAddressId) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .get("$baseUrl/$prefix/$v/$suffix/$dappAddressId",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DappAddressDto.fromJson(json);
    }));
  }

  @override
  Future<List<DappAddressDto>> findAll(FindDappAddressesQuery? query) async {
    final token = await tokenProvider.get();
    Map<String, dynamic>? queryJson;
    if (query != null) {
      var json = query.toJson();
      queryJson = Map.fromEntries(
          json.entries.where((element) => element.value != null));
    }
    return withReThrowingDataServiceError(Dio()
        .get("$baseUrl/$prefix/$v/$suffix",
            queryParameters: queryJson,
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final List<dynamic> list = value.data;
      return list.map((e) => DappAddressDto.fromJson(e)).toList();
    }));
  }

  @override
  Future<DappAddressDto> patch(
      String dappAddressId, PartialUpdateDappAddressCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .patch("$baseUrl/$prefix/$v/$suffix/$dappAddressId",
            data: command.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DappAddressDto.fromJson(json);
    }));
  }
}
