import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_addresses/data_service_wallet_addresses_dtos.dart';
import 'package:dio/dio.dart';

abstract class DataServiceWalletAddressesApi {
  Future<AddressDto> create(CreateAddressCommandDto command);
  Future delete(String addressId);
  Future<AddressDto> find(String addressId);
  Future<List<AddressDto>> findAll();
  Future<AddressDto> patch(String addressId, PatchAddressCommandDto command);
  Future resendVerificationCode(String addressId);
  Future<AddressDto> verify(String addressId, VerifyAddressCommandDto command);
}

class DataServiceWalletAddressesApiClient
    implements DataServiceWalletAddressesApi {
  final String baseUrl;
  final TokenProvider tokenProvider;

  final String prefix = "api";
  final String v = "v1";
  final String suffix = "wallets/me/addresses";

  DataServiceWalletAddressesApiClient(this.baseUrl, this.tokenProvider);

  @override
  Future<AddressDto> create(CreateAddressCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$prefix/$v/$suffix",
            data: command.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return AddressDto.fromJson(json);
    }));
  }

  @override
  Future delete(String addressId) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().delete(
        "$baseUrl/$prefix/$v/$suffix/$addressId",
        options: Options(headers: createHeaders(token))));
  }

  @override
  Future<AddressDto> find(String addressId) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .get("$baseUrl/$prefix/$v/$suffix/$addressId",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return AddressDto.fromJson(json);
    }));
  }

  @override
  Future<List<AddressDto>> findAll() async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .get("$baseUrl/$prefix/$v/$suffix",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final List<dynamic> list = value.data;
      return list.map((e) => AddressDto.fromJson(e)).toList();
    }));
  }

  @override
  Future<AddressDto> patch(
      String addressId, PatchAddressCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .patch("$baseUrl/$prefix/$v/$suffix/$addressId",
            data: command.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return AddressDto.fromJson(json);
    }));
  }

  @override
  Future resendVerificationCode(String addressId) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio().post(
        "$baseUrl/$prefix/$v/$suffix/$addressId/resendVerificationCode",
        data: {},
        options: Options(headers: createHeaders(token))));
  }

  @override
  Future<AddressDto> verify(
      String addressId, VerifyAddressCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$prefix/$v/$suffix/$addressId/verify",
            data: command.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return AddressDto.fromJson(json);
    }));
  }
}
