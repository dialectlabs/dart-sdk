import 'dart:convert';
import 'dart:typed_data';

import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:dialect_sdk/src/core/constants.dart';
import 'package:dialect_sdk/src/core/utils/nacl-utils.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/wallet-adapter/dialect-wallet-adapter.interface.dart';
import 'package:solana/solana.dart';

String bytesToBase64(Uint8List signature) {
  final encoded = base64Url.encode(signature);
  final replaced = encoded.replaceAll(RegExp(r'='), '');
  return replaced;
}

Uint8List decodeUrlSafe(String serialized) {
  final mod = serialized.length % 4;
  if (mod > 0) {
    serialized += '=' * (4 - mod);
  }
  return base64Url.decode(serialized);
}

Map<String, dynamic> fromBase64(String serialized) {
  final byteArray = decodeUrlSafe(serialized);
  final json = utf8.decode(byteArray);
  return JsonDecoder().convert(json);
}

String toBase64(String jsonString) {
  final byteArray = utf8.encode(jsonString);
  return bytesToBase64(Uint8List.fromList(byteArray));
}

class AuthTokensImpl implements AuthTokens {
  AuthTokensImpl();

  @override
  Future<Token> generate(Ed25519TokenSigner signer, Duration ttl) async {
    TokenHeader header = TokenHeader(alg: 'ed25519', typ: 'JWT');
    final headerStr = JsonEncoder().convert(header.toJson());
    final base64Header = toBase64(headerStr);
    final nowUtcSeconds = DateTime.now().millisecondsSinceEpoch / 1000;
    final body = TokenBody(
        sub: signer.subject.toBase58(),
        iat: nowUtcSeconds.round(),
        exp: (nowUtcSeconds + ttl.inMilliseconds / 1000).round());
    final bodyStr = JsonEncoder().convert(body.toJson());
    final base64Body = toBase64(bodyStr);

    final sigResult = await sign(base64Header, base64Body, signer);
    final rawValue = [base64Header, base64Body, sigResult.base64Signature]
        .join(AuthConstants.authDelimiter);
    return Token(
        rawValue: rawValue,
        header: header,
        body: body,
        signature: sigResult.signature,
        base64Signature: sigResult.base64Signature,
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
    final signingPayload = Uint8List.fromList(utf8.encode(signedPayload));
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
    try {
      final body = TokenBody.fromJson(fromBase64(base64Body));
      final header = TokenHeader.fromJson(fromBase64(base64Header));
      final signature = decodeUrlSafe(base64Signature);

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
      print("ERROR $e");
      throw TokenParsingError();
    }
  }

  Future<SigningResult> sign(
      String base64Header, String base64Body, Ed25519TokenSigner signer) async {
    final signingPayload = utf8
        .encode([base64Header, base64Body].join(AuthConstants.authDelimiter));
    final signature = await signer.sign(Uint8List.fromList(signingPayload));
    final base64Signature = bytesToBase64(signature);
    return SigningResult(signature, base64Signature);
  }
}

class DialectWalletAdapterEd25519TokenSigner implements Ed25519TokenSigner {
  Ed25519HDPublicKey _subject;
  final DialectWalletAdapter dialectWalletAdapter;

  DialectWalletAdapterEd25519TokenSigner({required this.dialectWalletAdapter})
      : _subject = dialectWalletAdapter.publicKey;

  @override
  Ed25519HDPublicKey get subject {
    return _subject;
  }

  @override
  set subject(Ed25519HDPublicKey _subj) {
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

class SigningResult {
  Uint8List signature;
  String base64Signature;
  SigningResult(this.signature, this.base64Signature);
}

// TODO: use base sdk error as a parent
class TokenParsingError extends Error {}

class TokenStructureValidationError extends Error {}
