import 'dart:typed_data';

import 'package:dialect_sdk/src/internal/auth/token-utils.dart';
import 'package:solana/solana.dart';

class Auth {
  static AuthTokens get tokens {
    return AuthTokensImpl();
  }
}

abstract class AuthTokens {
  Future<Token> generate(Ed25519TokenSigner signer, Duration ttl);
  bool isExpired(Token token);
  bool isSignatureValid(Token token);
  bool isValid(Token token);
  Token parse(String rawToken);
}

abstract class Ed25519TokenSigner {
  Ed25519HDKeyPair subject;

  Ed25519TokenSigner({required this.subject});

  Future<Uint8List> sign(Uint8List payload);
}

class Token {
  String rawValue;
  TokenHeader header;
  TokenBody body;
  Uint8List signature;
  String base64Header;
  String base64Body;
  String base64Signature;

  Token(
      {required this.rawValue,
      required this.header,
      required this.body,
      required this.signature,
      required this.base64Header,
      required this.base64Body,
      required this.base64Signature});

  Token.fromJson(Map<String, dynamic> json)
      : rawValue = json['rawValue'],
        header = TokenHeader.fromJson(json['header']),
        body = TokenBody.fromJson(json['iat']),
        signature = json['signature'],
        base64Header = json['base64Header'],
        base64Body = json['base64Body'],
        base64Signature = json['base64Signature'];

  Map<String, dynamic> toJson() {
    return {
      'rawValue': rawValue,
      'header': header.toJson(),
      'body': body.toJson(),
      'signature': signature,
      'base64Header': base64Header,
      'base64Body': base64Body,
      'base64Signature': base64Signature
    };
  }
}

class TokenBody {
  String sub;
  int? iat;
  int exp;

  TokenBody({required this.sub, this.iat, required this.exp});

  TokenBody.fromJson(Map<String, dynamic> json)
      : sub = json['sub'],
        exp = json['exp'],
        iat = json['iat'];

  Map<String, dynamic> toJson() {
    return {
      'sub': sub,
      'exp': exp,
      'iat': iat,
    };
  }
}

class TokenHeader {
  String? alg;
  String? typ;

  TokenHeader({this.alg, this.typ});

  TokenHeader.fromJson(Map<String, dynamic> json)
      : alg = json['alg'],
        typ = json['typ'];

  Map<String, dynamic> toJson() {
    return {
      'alg': alg,
      'typ': typ,
    };
  }
}
