import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:dialect_sdk/src/internal/auth/token-utils.dart';
import 'package:dialect_sdk/src/wallet-adapter/node-dialect-wallet-adapter.dart';
import 'package:test/test.dart';

import '../../interop-keypairs.dart';
import '../../interop-messaging-test-helpers.dart';

void main() async {
  group('Auth token tests', () {
    late NodeDialectWalletAdapter wallet;
    late Ed25519TokenSigner signer;
    late AuthTokens tokenUtils;

    setUp(() async {
      wallet =
          await NodeDialectWalletAdapter.create(keypair: await primaryKeyPair);
      signer =
          DialectWalletAdapterEd25519TokenSigner(dialectWalletAdapter: wallet);
      tokenUtils = AuthTokensImpl();
    });
    test('Validate ts token', () async {
      // TODO: enter a token generated in the ts SDK
      var rawToken = "";

      if (rawToken.isNotEmpty) {
        // when
        final token = tokenUtils.parse(rawToken);
        print(token.rawValue);

        // then
        final isValid = tokenUtils.isValid(token);
        expect(isValid, isTrue);
        final parsedToken = tokenUtils.parse(token.rawValue);
        final isParsedTokenValid = tokenUtils.isValid(parsedToken);
        expect(isParsedTokenValid, isTrue);
      } else {
        print("Set the above rawToken var to a token generated by the ts SDK");
      }
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));

    test('Validate dart token', () async {
      // when
      final token = await tokenUtils.generate(signer, Duration(seconds: 100));
      print(token.rawValue);

      // then
      final isValid = tokenUtils.isValid(token);
      expect(isValid, isTrue);
      final parsedToken = tokenUtils.parse(token.rawValue);
      final isParsedTokenValid = tokenUtils.isValid(parsedToken);
      expect(isParsedTokenValid, isTrue);
    }, timeout: Timeout(interopTestingConfig.timeoutDuration));
  }, timeout: Timeout(interopTestingConfig.timeoutDuration));
}