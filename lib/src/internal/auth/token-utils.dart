import 'dart:convert';
import 'dart:typed_data';

import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:dialect_sdk/src/core/constants.dart';
import 'package:dialect_sdk/src/core/extensions/byte-array-extensions.dart';
import 'package:dialect_sdk/src/core/extensions/string-extensions.dart';
import 'package:dialect_sdk/src/core/utils/nacl-utils.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter.interface.dart';
import 'package:solana/solana.dart';

class AuthTokensImpl implements AuthTokens {
  AuthTokensImpl();

  @override
  Future<Token> generate(Ed25519TokenSigner signer, Duration ttl) async {
    TokenHeader header = TokenHeader(alg: 'ed25519', typ: 'JWT');
    final headerStr = JsonEncoder().convert(header);
    final base64Header = headerStr.btoa();
    final nowUtcSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    final body = TokenBody(
        sub: signer.subject.publicKey.toBase58(),
        iat: nowUtcSeconds.round(),
        exp: (nowUtcSeconds + ttl.inMilliseconds / 1000).round());
    final bodyStr = JsonEncoder().convert(body);
    final base64Body = bodyStr.btoa();
    final signingPayload = AuthTokensImpl._getSigningPayload(
        [base64Header, base64Body].join(AuthConstants.authDelimiter));
    final signature = await signer.sign(signingPayload);
    final base64Signature = signature.encodeBase64();
    final rawValue = [base64Header, base64Body, base64Signature]
        .join(AuthConstants.authDelimiter);
    return Token(
        rawValue: rawValue,
        header: header,
        body: body,
        signature: signature,
        base64Signature: base64Signature,
        base64Body: base64Body,
        base64Header: base64Header);
  }

  @override
  bool isExpired(Token token) {
    final nowUtcSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    return nowUtcSeconds > token.body.exp;
  }

  @override
  bool isSignatureValid(Token token) {
    final signedPayload = [token.base64Header, token.base64Body]
        .join(AuthConstants.authDelimiter);
    final signingPayload = AuthTokensImpl._getSigningPayload(signedPayload);
    var pk = Ed25519HDPublicKey.fromBase58(token.body.sub);
    return NaClUtils.signDetachedVerify(
        signingPayload, token.signature, Uint8List.fromList(pk.bytes));
  }

  @override
  bool isValid(Token token) {
    if (!isSignatureValid(token)) {
      return false;
    }
    return !isExpired(token);
  }

  @override
  Token parse(String rawToken) {
    final parts = rawToken.split(AuthConstants.authDelimiter);

    if (parts.length != 3) {
      throw TokenParsingError();
    }
    final base64Header = parts[0];
    final base64Body = parts[1];
    final base64Signature = parts[2];
    if (base64Header.isEmpty || base64Body.isEmpty || base64Signature.isEmpty) {
      throw TokenParsingError();
    }
    final decoder = JsonDecoder();
    try {
      final body = TokenBody.fromJson(decoder.convert(base64Body.atob()));
      final header = TokenHeader.fromJson(decoder.convert(base64Header.atob()));
      final signature = base64Signature.decodeBase64();
      return Token(
          rawValue: rawToken,
          header: header,
          body: body,
          signature: signature,
          base64Header: base64Header,
          base64Body: base64Body,
          base64Signature: base64Signature);
    } catch (e) {
      // TODO: log
      throw TokenParsingError();
    }
  }

  static Uint8List _getSigningPayload(String signedPayload) {
    return Uint8List.fromList(
        signedPayload.btoa().split('').map((c) => c.codeUnitAt(0)).toList());
  }
}

class DialectWalletAdapterEd25519TokenSigner implements Ed25519TokenSigner {
  Ed25519HDKeyPair _subject;
  final DialectWalletAdapter dialectWalletAdapter;

  DialectWalletAdapterEd25519TokenSigner({required this.dialectWalletAdapter})
      : _subject = dialectWalletAdapter.publicKey;

  @override
  Ed25519HDKeyPair get subject {
    return _subject;
  }

  @override
  set subject(Ed25519HDKeyPair _subj) {
    _subject = _subj;
  }

  @override
  Future<Uint8List> sign(Uint8List payload) async {
    if (dialectWalletAdapter.signMessage == null) {
      throw UnsupportedOperationError(title: "", msg: "");
    }
    return dialectWalletAdapter.signMessage!(payload);
  }
}

// TODO: use base sdk error as a parent
class TokenParsingError extends Error {}

class TokenStructureValidationError extends Error {}
