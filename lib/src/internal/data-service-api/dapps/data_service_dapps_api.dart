import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_dapp_addresses/data_service_wallet_dapp_addresses_dtos.dart';
import 'package:dio/dio.dart';

abstract class DataServiceDappsApi {
  Future broadcast(BroadcastDappMessageCommandDto command);
  Future<DappDto> create(CreateDappCommandDtoPartial command);
  Future<DappDto> find();
  Future<List<DappDto>> findAll(FindDappQueryDto? query);
  Future<List<DappAddressDto>> findAllDappAddresses();
  Future multicast(MulticastDappMessageCommandDto command);
  Future unicast(UnicastDappMessageCommandDto command);
}

class DataServiceDappsApiClient implements DataServiceDappsApi {
  final String baseUrl;
  final TokenProvider tokenProvider;

  final String prefix = "api";
  final String v = "v1";
  final String suffix = "dapps";

  DataServiceDappsApiClient(this.baseUrl, this.tokenProvider);

  @override
  Future broadcast(BroadcastDappMessageCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().post(
        "$baseUrl/$prefix/$v/$suffix/${token.body.sub}/messages/broadcast",
        options: Options(headers: createHeaders(token)),
        data: command.toJson()));
  }

  @override
  Future<DappDto> create(CreateDappCommandDtoPartial command) async {
    final token = await tokenProvider.get();
    final fullCommand =
        CreateDappCommandDto(command.name, command.description, token.body.sub);
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$prefix/$v/$suffix",
            data: fullCommand.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DappDto.fromJson(json);
    }));
  }

  @override
  Future<DappDto> find() async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().get(
            "$baseUrl/$prefix/$v/$suffix/${token.body.sub}",
            options: Options(headers: createHeaders(token))))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DappDto.fromJson(json);
    });
  }

  @override
  Future<List<DappDto>> findAll(FindDappQueryDto? query) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().get(
            "$baseUrl/$prefix/$v/$suffix",
            queryParameters: query?.toJson(),
            options: Options(headers: createHeaders(token))))
        .then((value) {
      final List<dynamic> list = value.data;
      return list.map((e) => DappDto.fromJson(e)).toList();
    });
  }

  @override
  Future<List<DappAddressDto>> findAllDappAddresses() async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .get("$baseUrl/$prefix/$v/$suffix/${token.body.sub}/dappAddresses",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final List<dynamic> json = value.data;
      return json.map((e) => DappAddressDto.fromJson(e)).toList();
    }));
  }

  @override
  Future multicast(MulticastDappMessageCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().post(
        "$baseUrl/$prefix/$v/$suffix/${token.body.sub}/messages/multicast",
        options: Options(headers: createHeaders(token)),
        data: command.toJson()));
  }

  @override
  Future unicast(UnicastDappMessageCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().post(
        "$baseUrl/$prefix/$v/$suffix/${token.body.sub}/messages/unicast",
        options: Options(headers: createHeaders(token)),
        data: command.toJson()));
  }
}
