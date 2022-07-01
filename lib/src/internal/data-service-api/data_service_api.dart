import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/data_service_dapps_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dialects/data_service_dialects_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/v0/data_service_wallets_api.v0.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_addresses/data_service_wallet_addresses_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_dapp_addresses/data_service_wallet_dapp_addresses_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_messages_api/data_service_wallet_messages_api.dart';
import 'package:dio/dio.dart';
import 'package:nanoid/nanoid.dart';

const XRequestIdHeader = 'x-request-id';

Map<String, String> createHeaders(Token token) {
  return {
    "Authorization": "Bearer ${token.rawValue}",
    XRequestIdHeader: nanoid()
  };
}

Future<T> withReThrowingDataServiceError<T>(Future<T> fn) async {
  try {
    return await fn;
  } catch (e) {
    if (e is DioError) {
      if (e.response == null) {
        throw NetworkError();
      }

      String message = "";
      final data = e.response!.data;
      if (data is Map<String, dynamic> && data.containsKey("message")) {
        message = data["message"].toString();
      }
      final requestId = (e.requestOptions.headers[XRequestIdHeader] is String)
          ? e.requestOptions.headers[XRequestIdHeader] as String
          : null;

      throw DataServiceApiError(
          message, e.response!.statusMessage, e.response!.statusCode,
          requestId: requestId);
    }
    rethrow;
  }
}

class DataServiceApi {
  final DataServiceDialectsApi threads;
  final DataServiceDappsApi dapps;
  final DataServiceWalletsApiV0 walletsV0;
  final DataServiceWalletAddressesApi walletAddresses;
  final DataServiceWalletDappAddressesApi walletDappAddresses;
  final DataServiceWalletMessagesApi walletMessages;

  DataServiceApi(
      {required this.threads,
      required this.dapps,
      required this.walletsV0,
      required this.walletAddresses,
      required this.walletDappAddresses,
      required this.walletMessages});

  static DataServiceApi create(String baseUrl, TokenProvider tokenProvider) {
    final dialectsApi = DataServiceDialectsApiClient(
        baseUrl: baseUrl, tokenProvider: tokenProvider);
    final dappAddressesApi = DataServiceDappsApiClient(baseUrl, tokenProvider);
    final walletsApiV0 = DataServiceWalletsApiClientV0(baseUrl, tokenProvider);
    final walletAddressesApi =
        DataServiceWalletAddressesApiClient(baseUrl, tokenProvider);
    final walletDappAddressesApi =
        DataServiceWalletDappAddressesApiClient(baseUrl, tokenProvider);
    final walletDappMessagesApi =
        DataServiceWalletMessagesApiClient(baseUrl, tokenProvider);
    return DataServiceApi(
        threads: dialectsApi,
        dapps: dappAddressesApi,
        walletsV0: walletsApiV0,
        walletAddresses: walletAddressesApi,
        walletDappAddresses: walletDappAddressesApi,
        walletMessages: walletDappMessagesApi);
  }
}

class DataServiceApiClientError {
  NetworkError? networkError;
  DataServiceApiError? dataServiceApiError;
  DataServiceApiClientError.fromDataServiceApiError(this.dataServiceApiError);
  DataServiceApiClientError.fromNetworkError(this.networkError);
}

class DataServiceApiError implements Exception {
  String message;
  String? error;
  int? statusCode;
  String? requestId;
  DataServiceApiError(this.message, this.error, this.statusCode,
      {this.requestId});
}

class NetworkError {}

class RawDataServiceApiError {
  late String message;
  RawDataServiceApiError(this.message);
}
