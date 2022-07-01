import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/auth/token_utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_messages_api/data_service_wallet_messages_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_messages_api/data_service_wallet_messages_dtos.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect_wallet_adapter_wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/node_dialect_wallet_adapter.dart';
import 'package:test/test.dart';

void main() async {
  group('Data service wallet messages api (e2e)', () {
    const baseUrl = 'http://localhost:8080';

    late DialectWalletAdapterWrapper dappWallet;
    late DataServiceWalletMessagesApi dappsApi;

    setUp(() async {
      dappWallet = DialectWalletAdapterWrapper(
          delegate: await NodeDialectWalletAdapter.create());
      dappsApi = DataServiceApi.create(
              baseUrl,
              TokenProvider.create(
                  signer: DialectWalletAdapterEd25519TokenSigner(
                      dialectWalletAdapter: dappWallet)))
          .walletMessages;
    });

    test('can find all dapp messages', () async {
      // when
      final addresses1 = await dappsApi.findAllDappMessages();
      final addresses2 = await dappsApi.findAllDappMessages(
          query: FindWalletMessagesQueryDto(take: 1));
      final addresses3 = await dappsApi.findAllDappMessages(
          query: FindWalletMessagesQueryDto(take: 3));
      // then
      expect(addresses1, equals([]));
      expect(addresses2, equals([]));
      expect(addresses3, equals([]));
    });
  });
}
