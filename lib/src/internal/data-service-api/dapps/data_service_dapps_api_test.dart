import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/auth/token_utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/data_service_dapps_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/v0/data_service_wallets_api.v0.dart';
import 'package:dialect_sdk/src/internal/data-service-api/v0/data_service_wallets_dtos.v0.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect_wallet_adapter_wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/node_dialect_wallet_adapter.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() async {
  group('Data service dapps api (e2e)', () {
    const baseUrl = 'http://localhost:8080';
    late DialectWalletAdapterWrapper dappWallet;
    late DataServiceDappsApi dappsApi;

    setUp(() async {
      dappWallet = DialectWalletAdapterWrapper(
          delegate: await NodeDialectWalletAdapter.create());
      dappsApi = DataServiceApi.create(
              baseUrl,
              TokenProvider.create(
                  signer: DialectWalletAdapterEd25519TokenSigner(
                      dialectWalletAdapter: dappWallet)))
          .dapps;
    });

    test('can create dapp and find all dappAddresses', () async {
      // when
      final created =
          await dappsApi.create(CreateDappCommandDtoPartial("Test dapp"));
      final addresses = await dappsApi.findAllDappAddresses();
      // then
      final dappDtoExpected = DappDto(
          created.id, dappWallet.publicKey.toBase58(), created.name, false);
      expect(created, equals(dappDtoExpected));
      expect(addresses, equals([]));
    });

    test('can find dapp', () async {
      // given
      await expectLater(dappsApi.find(), throwsException);
      // when
      final created =
          await dappsApi.create(CreateDappCommandDtoPartial("Test dapp"));
      final addresses = await dappsApi.findAllDappAddresses();
      // then
      final dappDtoExpected = DappDto(
          created.id, dappWallet.publicKey.toBase58(), created.name, false);
      expect(created, equals(dappDtoExpected));
      expect(addresses, equals([]));
    });

    test('can find all dapps', () async {
      // given
      await expectLater(dappsApi.find(), throwsException);
      final created =
          await dappsApi.create(CreateDappCommandDtoPartial("Test dapp"));
      // when
      final found = await dappsApi.findAll(FindDappQueryDto(false));
      // then
      expect(found.contains(created), equals(true));
      // when
      final foundWithFilter = await dappsApi.findAll(FindDappQueryDto(true));
      // then
      expect(foundWithFilter.contains(created), equals(false));
    });

    test('can unicast notification', () async {
      // given
      await dappsApi.create(CreateDappCommandDtoPartial("Test dapp"));
      // when / then
      await expectLater(
          dappsApi.unicast(UnicastDappMessageCommandDto("test-title", "test",
              (await Ed25519HDKeyPair.random()).publicKey.toBase58())),
          completes);
    });

    test('can multicast notification', () async {
      // given
      await dappsApi.create(CreateDappCommandDtoPartial("Test dapp"));
      // when / then
      await expectLater(
          dappsApi
              .multicast(MulticastDappMessageCommandDto("test-title", "test", [
            (await Ed25519HDKeyPair.random()).publicKey.toBase58(),
            (await Ed25519HDKeyPair.random()).publicKey.toBase58()
          ])),
          completes);
    });

    test('can broadcast notification', () async {
      // given
      await dappsApi.create(CreateDappCommandDtoPartial("Test dapp"));
      // when / then
      await expectLater(
          dappsApi
              .broadcast(BroadcastDappMessageCommandDto("test-title", "test")),
          completes);
    });

    group('Wallet dapp addresses v0', () {
      late DialectWalletAdapterWrapper wallet;
      late DataServiceWalletsApiV0 wallets;
      late DataServiceDappsApi dapps;

      setUp(() async {
        wallet = DialectWalletAdapterWrapper(
            delegate: await NodeDialectWalletAdapter.create());
        final dataServiceApi = DataServiceApi.create(
            baseUrl,
            TokenProvider.create(
                signer: DialectWalletAdapterEd25519TokenSigner(
                    dialectWalletAdapter: wallet)));
        wallets = dataServiceApi.walletsV0;
        dapps = dataServiceApi.dapps;
      });

      test('can create dapp address', () async {
        // given
        final dapp =
            await dapps.create(CreateDappCommandDtoPartial("Test dapp"));
        // when
        final createDappAddressCommand = CreateAddressCommandV0(
            type: 'wallet', value: wallet.publicKey.toBase58(), enabled: true);
        final dappAddressDtoV0 = await wallets.createDappAddress(
            createDappAddressCommand, dapp.publicKey);
        // then
        final expected = DappAddressDtoV0(
            addressId: dappAddressDtoV0.addressId,
            id: dappAddressDtoV0.id,
            type: AddressTypeV0.wallet,
            enabled: true,
            verified: true,
            dapp: dapp.publicKey,
            value: wallet.publicKey.toBase58());
        expect(dappAddressDtoV0, equals(expected));
      });

      test('can find dapp address', () async {
        // given
        final dapp =
            await dapps.create(CreateDappCommandDtoPartial("Test dapp"));
        final createDappAddressCommand = CreateAddressCommandV0(
            type: 'wallet', value: wallet.publicKey.toBase58(), enabled: true);
        await wallets.createDappAddress(
            createDappAddressCommand, dapp.publicKey);
        // when
        final dappAddressDtoV0s =
            await wallets.findAllDappAddresses(dapp.publicKey);
        expect(dappAddressDtoV0s.length, equals(1));
        final dappAddressDtoV0 = dappAddressDtoV0s.first;
        // then
        final expected = DappAddressDtoV0(
            id: dappAddressDtoV0.id,
            type: AddressTypeV0.wallet,
            verified: true,
            addressId: dappAddressDtoV0.addressId,
            dapp: dapp.publicKey,
            enabled: true,
            value: dappAddressDtoV0.value);
        expect(dappAddressDtoV0s, equals([expected]));
      });

      test('can delete dapp address', () async {
        // given
        final dapp =
            await dapps.create(CreateDappCommandDtoPartial("Test dapp"));
        final createDappAddressCommand = CreateAddressCommandV0(
            type: 'wallet', value: wallet.publicKey.toBase58(), enabled: true);
        final addressDtoV0 = await wallets.createDappAddress(
            createDappAddressCommand, dapp.publicKey);
        // when
        await wallets.deleteDappAddress(
            DeleteAddressCommandV0(id: addressDtoV0.addressId));
        final dappAddressDtoV0s =
            await wallets.findAllDappAddresses(dapp.publicKey);
        // then
        expect(dappAddressDtoV0s, equals([]));
      });
    });
  });
}
