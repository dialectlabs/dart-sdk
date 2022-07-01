import 'package:dialect_sdk/src/internal/auth/token_provider.dart';
import 'package:dialect_sdk/src/internal/auth/token_utils.dart';
import 'package:dialect_sdk/src/internal/data-service-api/dapps/dapp_client_dtos.dart';
import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_addresses/data_service_wallet_addresses_api.dart';
import 'package:dialect_sdk/src/internal/data-service-api/wallet_addresses/data_service_wallet_addresses_dtos.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect_wallet_adapter_wrapper.dart';
import 'package:dialect_sdk/src/wallet-adapter/node_dialect_wallet_adapter.dart';
import 'package:test/test.dart';

void main() async {
  group('Data service wallet addresses api (e2e)', () {
    const baseUrl = 'http://localhost:8080';

    // TODO: cleanup created resources after tests
    late DialectWalletAdapterWrapper wallet;
    late DataServiceWalletAddressesApi api;

    setUp(() async {
      wallet = DialectWalletAdapterWrapper(
          delegate: await NodeDialectWalletAdapter.create());

      api = DataServiceApi.create(
              baseUrl,
              TokenProvider.create(
                  signer: DialectWalletAdapterEd25519TokenSigner(
                      dialectWalletAdapter: wallet)))
          .walletAddresses;
    });

    test('can create wallet address', () async {
      // when
      final command = CreateAddressCommandDto(
          wallet.publicKey.toBase58(), AddressTypeDto.wallet);
      final created = await api.create(command);
      // then
      final addressDtoExpected = AddressDto(
          created.id,
          command.type,
          true,
          command.value,
          WalletDto(created.wallet.id, wallet.publicKey.toBase58()));
      expect(created, equals(addressDtoExpected));
    });

    test('can get wallet address by id after creating', () async {
      // given
      final command = CreateAddressCommandDto(
          wallet.publicKey.toBase58(), AddressTypeDto.wallet);
      final created = await api.create(command);
      // when
      final found = await api.find(created.id);
      // then
      final addressDtoExpected = AddressDto(
          created.id,
          command.type,
          true,
          command.value,
          WalletDto(created.wallet.id, wallet.publicKey.toBase58()));
      expect(found, equals(addressDtoExpected));
    });

    test('can find wallet address after creating', () async {
      // given
      final command1 = CreateAddressCommandDto(
          wallet.publicKey.toBase58(), AddressTypeDto.wallet);
      final address1 = await api.create(command1);
      final command2 =
          CreateAddressCommandDto("kevin@dialect.to", AddressTypeDto.email);
      final address2 = await api.create(command2);
      // when
      final found = await api.findAll();
      // then
      final addressDto1Expected = AddressDto(
          address1.id,
          command1.type,
          true,
          command1.value,
          WalletDto(address1.wallet.id, wallet.publicKey.toBase58()));
      final addressDto2Expected = AddressDto(
          address2.id,
          command2.type,
          false,
          command2.value,
          WalletDto(address2.wallet.id, wallet.publicKey.toBase58()));
      expect(found, equals([addressDto1Expected, addressDto2Expected]));
    });

    test('can patch wallet address after creating', () async {
      // given
      final createCommand =
          CreateAddressCommandDto("kevin@dialect.to", AddressTypeDto.email);
      final createdAddressDto = await api.create(createCommand);
      // when
      final patchCommand = PatchAddressCommandDto("kevin-dev@dialect.to");
      final patched = await api.patch(createdAddressDto.id, patchCommand);
      final foundAfterPatch = await api.find(patched.id);
      // then
      final addressDtoExpected = AddressDto(
          foundAfterPatch.id,
          createCommand.type,
          false,
          patchCommand.value!,
          WalletDto(foundAfterPatch.wallet.id, wallet.publicKey.toBase58()));
      expect(foundAfterPatch, equals(addressDtoExpected));
    });

    test('can delete wallet address', () async {
      // given
      final createCommand =
          CreateAddressCommandDto("kevin@dialect.to", AddressTypeDto.email);
      final createdAddressDto = await api.create(createCommand);
      // when
      await api.delete(createdAddressDto.id);
      // then
      expectLater(api.find(createdAddressDto.id), throwsException);
    });

    test('can verify wallet address', () async {
      // given
      final createCommand =
          CreateAddressCommandDto("kevin@dialect.to", AddressTypeDto.email);
      final createdAddressDto = await api.create(createCommand);
      // when
      final verifiedAddressDto = await api.verify(
          createdAddressDto.id, VerifyAddressCommandDto("811108"));
      // then
      final addressDtoExpected = AddressDto(
          verifiedAddressDto.id,
          createCommand.type,
          true,
          createCommand.value,
          WalletDto(verifiedAddressDto.wallet.id, wallet.publicKey.toBase58()));
      expect(verifiedAddressDto, equals(addressDtoExpected));
    });

    test('can resend verification code for wallet address', () async {
      // given
      final createCommand = CreateAddressCommandDto(
          wallet.publicKey.toBase58(), AddressTypeDto.wallet);
      final createdAddressDto = await api.create(createCommand);
      // when
      await expectLater(
          api.resendVerificationCode(createdAddressDto.id), completes);
    });
  });
}
