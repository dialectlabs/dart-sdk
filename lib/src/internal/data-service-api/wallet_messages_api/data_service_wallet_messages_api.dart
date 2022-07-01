import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_messages_api/data_service_wallet_messages_dtos.dart';
import 'package:dio/dio.dart';

abstract class DataServiceWalletMessagesApi {
  Future<List<MessageDto>> findAllDappMessages(
      {FindWalletMessagesQueryDto? query});
}

class DataServiceWalletMessagesApiClient
    implements DataServiceWalletMessagesApi {
  final String baseUrl;
  final TokenProvider tokenProvider;

  final String prefix = "api";
  final String v = "v1";
  final String suffix = "wallets/me/dappAddresses";

  DataServiceWalletMessagesApiClient(this.baseUrl, this.tokenProvider);

  @override
  Future<List<MessageDto>> findAllDappMessages(
      {FindWalletMessagesQueryDto? query}) async {
    final token = await tokenProvider.get();
    return withReThrowingDataServiceError(Dio()
        .get("$baseUrl/$prefix/$v/$suffix",
            queryParameters: query?.toJson(),
            options: Options(headers: createHeaders(token)))
        .then((value) {
      final List<dynamic> list = value.data;
      return list.map((e) => MessageDto.fromJson(e)).toList();
    }));
  }
}
