import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/auth/token_utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/data_service_dapps_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_addresses/data_service_wallet_addresses_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_dapp_addresses/data_service_wallet_dapp_addresses_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_dapp_addresses/data_service_wallet_dapp_addresses_dtos.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect_wallet_adapter_wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/node_dialect_wallet_adapter.dart';
import 'package:test/test.dart';

void main() async {
  group('Data service wallet dapp addresses api (e2e)', () {
    const baseUrl = 'http://localhost:8080';

    // TODO: cleanup created resources after tests
    late DialectWalletAdapterWrapper wallet;
    late DataServiceWalletDappAddressesApi walletDappAddressesApi;

    late DialectWalletAdapterWrapper dappWallet;
    late DataServiceDappsApi dappApi;

    late DappDto dappDto;
    late AddressDto walletAddress;

    setUp(() async {
      wallet = DialectWalletAdapterWrapper(
          delegate: await NodeDialectWalletAdapter.create());
      final walletDataServiceApi = DataServiceApi.create(
          baseUrl,
          TokenProvider.create(
              signer: DialectWalletAdapterEd25519TokenSigner(
                  dialectWalletAdapter: wallet)));
      walletDappAddressesApi = walletDataServiceApi.walletDappAddresses;
      dappWallet = DialectWalletAdapterWrapper(
          delegate: await NodeDialectWalletAdapter.create());
      dappApi = DataServiceApi.create(
              baseUrl,
              TokenProvider.create(
                  signer: DialectWalletAdapterEd25519TokenSigner(
                      dialectWalletAdapter: dappWallet)))
          .dapps;
      dappDto = await dappApi.create(CreateDappCommandDtoPartial("Test dapp"));
      walletAddress = await walletDataServiceApi.walletAddresses.create(
          CreateAddressCommandDto(
              wallet.publicKey.toBase58(), AddressTypeDto.wallet));
    });

    test('can create wallet dapp address', () async {
      // when
      final command = CreateDappAddressCommandDto(
          dappDto.publicKey, walletAddress.id, true);
      final created = await walletDappAddressesApi.create(command);
      // then
      final dappAddressDtoExpected =
          DappAddressDto(created.id, true, created.channelId, walletAddress);
      expect(created, equals(dappAddressDtoExpected));
    });

    test('can get wallet dapp address by id after creating', () async {
      // given
      final command = CreateDappAddressCommandDto(
          dappDto.publicKey, walletAddress.id, true);
      final created = await walletDappAddressesApi.create(command);
      // when
      final foundDappAddress = await walletDappAddressesApi.find(created.id);
      // then
      final dappAddressDtoExpected =
          DappAddressDto(created.id, true, created.channelId, walletAddress);
      expect(foundDappAddress, equals(dappAddressDtoExpected));
    });

    test('can find wallet dapp address after creating', () async {
      // given
      final command = CreateDappAddressCommandDto(
          dappDto.publicKey, walletAddress.id, true);
      final created = await walletDappAddressesApi.create(command);
      // when
      final foundDappAddresses = await walletDappAddressesApi.findAll(null);
      final foundDappAddressesByDappId = await walletDappAddressesApi
          .findAll(FindDappAddressesQuery(dappPublicKey: dappDto.publicKey));
      final foundDappAddressesByAddressesd = await walletDappAddressesApi
          .findAll(FindDappAddressesQuery(addressIds: [walletAddress.id]));
      // then
      final dappAddressDtoExpected =
          DappAddressDto(created.id, true, created.channelId, walletAddress);
      expect(foundDappAddresses, equals([dappAddressDtoExpected]));
      expect(foundDappAddressesByDappId, equals([dappAddressDtoExpected]));
      expect(foundDappAddressesByAddressesd, equals([dappAddressDtoExpected]));
    });

    test('can patch wallet dapp address after creating', () async {
      // given
      final command = CreateDappAddressCommandDto(
          dappDto.publicKey, walletAddress.id, true);
      final created = await walletDappAddressesApi.create(command);
      // when
      final patchCommand = PartialUpdateDappAddressCommandDto(false);
      final patched =
          await walletDappAddressesApi.patch(created.id, patchCommand);
      final foundAfterPatch = await walletDappAddressesApi.find(patched.id);
      // then
      final dappAddressDtoExpected = DappAddressDto(
          foundAfterPatch.id, true, created.channelId, walletAddress);
      expect(patched, equals(dappAddressDtoExpected));
      expect(foundAfterPatch, equals(dappAddressDtoExpected));
    });

    test('can delete wallet dapp address', () async {
      // given
      final command = CreateDappAddressCommandDto(
          dappDto.publicKey, walletAddress.id, true);
      final created = await walletDappAddressesApi.create(command);
      // when
      await walletDappAddressesApi.delete(created.id);
      // then
      await expectLater(
          walletDappAddressesApi.find(created.id), throwsException);
    });
  });
}
