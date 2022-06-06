import 'dart:convert';

import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:dialect_sdk/src/core/constants.dart';
import 'package:dialect_sdk/src/core/extensions/string-extensions.dart';
import 'package:dialect_sdk/src/internal/auth/token-utils.dart';
import 'package:dialect_sdk/src/wallet-adapter/node-dialect-wallet-adapter.dart';
import 'package:solana/solana.dart';
import 'package:test/test.dart';

void main() {
  group('token tests', () {
    late NodeDialectWalletAdapter wallet;
    late Ed25519TokenSigner signer;
    late AuthTokens tokenUtils;

    setUp(() async {
      wallet = await NodeDialectWalletAdapter.create();
      signer =
          DialectWalletAdapterEd25519TokenSigner(dialectWalletAdapter: wallet);
      tokenUtils = AuthTokensImpl();
    });

    test('when not expired validation returns true', () async {
      // when
      final token = await tokenUtils.generate(signer, Duration(seconds: 100));

      // then
      final isValid = tokenUtils.isValid(token);
      expect(isValid, isTrue);
      final parsedToken = tokenUtils.parse(token.rawValue);
      final isParsedTokenValid = tokenUtils.isValid(parsedToken);
      expect(isParsedTokenValid, isTrue);
    });

    test('when expired validation returns false', () async {
      // when
      final token = await tokenUtils.generate(signer, Duration(seconds: -100));

      // then
      final isValid = tokenUtils.isValid(token);
      expect(isValid, isFalse);
      final parsedToken = tokenUtils.parse(token.rawValue);
      final isParsedTokenValid = tokenUtils.isValid(parsedToken);
      expect(isParsedTokenValid, isFalse);
    });

    test('when sub compromised returns false', () async {
      // when
      final token = await tokenUtils.generate(signer, Duration(minutes: 5));

      // then
      final isValid = tokenUtils.isValid(token);
      expect(isValid, isTrue);
      final sub = await Ed25519HDKeyPair.random();
      final compromisedBody = TokenBody(
          sub: sub.publicKey.toBase58(),
          exp: token.body.exp,
          iat: token.body.iat);
      final compromisedBase64Body =
          JsonEncoder().convert(compromisedBody).btoa();
      final compromisedToken = tokenUtils.parse([
        token.base64Header,
        compromisedBase64Body,
        token.base64Signature
      ].join(AuthConstants.authDelimiter));
      final isParsedTokenValid = tokenUtils.isValid(compromisedToken);
      expect(isParsedTokenValid, isFalse);
    });

    test('when exp compromised returns false', () async {
      // when
      final token = await tokenUtils.generate(signer, Duration(minutes: 5));

      // then
      final isValid = tokenUtils.isValid(token);
      expect(isValid, isTrue);
      final compromisedBody = TokenBody(
          sub: token.body.sub,
          exp: token.body.exp + 10000,
          iat: token.body.iat);
      final compromisedBase64Body =
          JsonEncoder().convert(compromisedBody).btoa();
      final compromisedToken = tokenUtils.parse([
        token.base64Header,
        compromisedBase64Body,
        token.base64Signature
      ].join(AuthConstants.authDelimiter));
      final isParsedTokenValid = tokenUtils.isValid(compromisedToken);
      expect(isParsedTokenValid, isFalse);
    });
  });
}
