import 'dart:typed_data';

import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dtos/dapp-client-dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dtos/data-service-dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/token-provider.dart';
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
        message = e.response!.data["message"];
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
  DataServiceApi({required this.threads});

  static DataServiceApi create(String baseUrl, TokenProvider tokenProvider) {
    final dialectsApi = DataServiceDialectsApiClient(
        baseUrl: baseUrl, tokenProvider: tokenProvider);
    return DataServiceApi(threads: dialectsApi);
  }
}

class DataServiceApiClientError {
  NetworkError? networkError;
  DataServiceApiError? dataServiceApiError;
  DataServiceApiClientError.fromDataServiceApiError(this.dataServiceApiError);
  DataServiceApiClientError.fromNetworkError(this.networkError);
}

class DataServiceApiError {
  String message;
  String? error;
  int? statusCode;
  String? requestId;
  DataServiceApiError(this.message, this.error, this.statusCode,
      {this.requestId});
}

abstract class DataServiceDappsApi {
  Future<DappDto> create(CreateDappCommandDto command);
  Future<List<DappAddressDto>> findAllDappAddresses();
}

class DataServiceDappsApiClient implements DataServiceDappsApi {
  final String baseUrl;
  final TokenProvider tokenProvider;

  final String prefix = "api";
  final String v = "v1";
  final String dapps = "dapps";
  final String dappAddresses = "dappAddresses";

  DataServiceDappsApiClient(this.baseUrl, this.tokenProvider);
  @override
  Future<DappDto> create(CreateDappCommandDto command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$prefix/$v/$dapps",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DappDto.fromJson(json);
    }));
  }

  @override
  Future<List<DappAddressDto>> findAllDappAddresses() async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$prefix/$v/$dapps/${token.body.sub}/$dappAddresses",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final List<dynamic> json = value.data;
      return json.map((e) => DappAddressDto.fromJson(e)).toList();
    }));
  }
}

abstract class DataServiceDialectsApi {
  Future<DialectAccountDto> create(CreateDialectCommand command);
  Future delete(String publicKey);
  Future<DialectAccountDto> find(String publicKey);
  Future<List<DialectAccountDto>> findAll({FindDialectQuery? query});
  Future<DialectAccountDto?> sendMessage(
      String publicKey, SendMessageCommand command);
}

class DataServiceDialectsApiClient implements DataServiceDialectsApi {
  final String baseUrl;
  final TokenProvider tokenProvider;

  final String prefix = "api";
  final String v = "v1";
  final String dialects = "dialects";
  final String messages = "messages";

  DataServiceDialectsApiClient(
      {required this.baseUrl, required this.tokenProvider});

  @override
  Future<DialectAccountDto> create(CreateDialectCommand command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$prefix/$v/$dialects",
            options: Options(headers: createHeaders(token)),
            data: command.toJson())
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DialectAccountDto.fromJson(json);
    }));
  }

  @override
  Future delete(String publicKey) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .delete("$baseUrl/$prefix/$v/$dialects/$publicKey",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      return value.data;
    }));
  }

  @override
  Future<DialectAccountDto> find(String publicKey) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .get("$baseUrl/$prefix/$v/$dialects/$publicKey",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DialectAccountDto.fromJson(json);
    }));
  }

  @override
  Future<List<DialectAccountDto>> findAll({FindDialectQuery? query}) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .get("$baseUrl/$prefix/$v/$dialects",
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final list = value.data as List<dynamic>;
      return list.map((json) => DialectAccountDto.fromJson(json)).toList();
    }));
  }

  @override
  Future<DialectAccountDto?> sendMessage(
      String publicKey, SendMessageCommand command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .post("$baseUrl/$prefix/$v/$dialects/$publicKey/$messages",
            data: command.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final Map<String, dynamic> json = value.data;
      return DialectAccountDto.fromJson(json);
    }));
  }
}

class FindDialectQuery {
  String? memberPublicKey;
  FindDialectQuery({required this.memberPublicKey});
}

class NetworkError {}

class RawDataServiceApiError {
  late String message;
  RawDataServiceApiError(this.message);
}

class SendMessageCommand {
  final Uint8List text;
  SendMessageCommand(this.text);

  Map<String, dynamic> toJson() => {"text": text};
}
