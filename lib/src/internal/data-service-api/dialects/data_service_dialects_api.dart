import 'dart:typed_data';

import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_dtos.dart';
import 'package:dio/dio.dart';

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

class SendMessageCommand {
  final Uint8List text;
  SendMessageCommand(this.text);

  Map<String, dynamic> toJson() => {"text": text};
}
