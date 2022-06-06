import 'dart:convert';

import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dtos/data-service-dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/token-provider.dart';
import 'package:http/http.dart' as http;

Future<T> withReThrowingDataServiceError<T>(Future<T> fn) async {
  try {
    return await fn;
  } catch (e) {
    final err = e as http.ClientException;
    throw Exception(err.message);
  }
}

class DataServiceApi {
  final DataServiceDialectsApi dialects;
  DataServiceApi({required this.dialects});

  static DataServiceApi create(String baseUrl, TokenProvider tokenProvider) {
    final dialectsApi = DataServiceDialectsApiClient(
        baseUrl: baseUrl, tokenProvider: tokenProvider);
    return DataServiceApi(dialects: dialectsApi);
  }
}

abstract class DataServiceDialectsApi {
  Future<DialectAccountDto> create(CreateDialectCommand command);
  Future delete(String publicKey);
  Future<DialectAccountDto?> find(String publicKey);
  Future<List<DialectAccountDto?>> findAll();
  Future<DialectAccountDto?> sendMessage(
      String publicKey, SendMessageCommand command);
}

class DataServiceDialectsApiClient implements DataServiceDialectsApi {
  final String baseUrl;
  final TokenProvider tokenProvider;

  final String v0 = "v0";
  final String dialects = "dialects";
  final String messages = "messages";

  DataServiceDialectsApiClient(
      {required this.baseUrl, required this.tokenProvider});

  Map<String, String> authHeaders(Token token) {
    return {"Authorization": "Bearer ${token.rawValue}"};
  }

  @override
  Future<DialectAccountDto> create(CreateDialectCommand command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(http
        .post(Uri.parse("$baseUrl/$v0/$dialects"),
            headers: authHeaders(token), body: command.toJson())
        .then((value) {
      return DialectAccountDto.fromJson(JsonDecoder().convert(value.body));
    }));
  }

  @override
  Future delete(String publicKey) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(http
        .delete(Uri.parse("$baseUrl/$v0/$dialects/$publicKey"),
            headers: authHeaders(token))
        .then((value) {
      return value.body;
    }));
  }

  @override
  Future<DialectAccountDto?> find(String publicKey) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(http
        .get(Uri.parse("$baseUrl/$v0/$dialects/$publicKey"),
            headers: authHeaders(token))
        .then((value) {
      return DialectAccountDto.fromJson(JsonDecoder().convert(value.body));
    }));
  }

  @override
  Future<List<DialectAccountDto>> findAll() async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(http
        .get(Uri.parse("$baseUrl/$v0/$dialects"), headers: authHeaders(token))
        .then((value) {
      return JsonDecoder()
          .convert(value.body)
          .map((json) => DialectAccountDto.fromJson(json))
          .toList();
    }));
  }

  @override
  Future<DialectAccountDto?> sendMessage(
      String publicKey, SendMessageCommand command) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(http
        .post(Uri.parse("$baseUrl/$v0/$dialects/$publicKey/$messages"),
            body: command.toJson(), headers: authHeaders(token))
        .then((value) {
      return DialectAccountDto.fromJson(JsonDecoder().convert(value.body));
    }));
  }
}
