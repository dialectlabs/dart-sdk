import 'dart:typed_data';

import 'package:dialect_sdk/src/core/converters/uint8list_converter.dart';
import 'package:dialect_sdk/src/internal/auth/token_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:solana/solana.dart';

part 'auth.interface.g.dart';

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
  Ed25519HDPublicKey subject;

  Ed25519TokenSigner({required this.subject});

  Future<Uint8List> sign(Uint8List payload);
}

@JsonSerializable(explicitToJson: true)
@Uint8ListConverter()
class Token {
  @JsonKey(name: "rawValue")
  String rawValue;
  @JsonKey(name: "header")
  TokenHeader header;
  @JsonKey(name: "body")
  TokenBody body;
  @JsonKey(name: "signature")
  Uint8List signature;
  @JsonKey(name: "base64Header")
  String base64Header;
  @JsonKey(name: "base64Body")
  String base64Body;
  @JsonKey(name: "base64Signature")
  String base64Signature;

  Token(
      {required this.rawValue,
      required this.header,
      required this.body,
      required this.signature,
      required this.base64Header,
      required this.base64Body,
      required this.base64Signature});

  factory Token.fromJson(Map<String, dynamic> json) => _$TokenFromJson(json);

  Map<String, dynamic> toJson() => _$TokenToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TokenBody {
  @JsonKey(name: "sub")
  String sub;
  @JsonKey(name: "iat")
  int? iat;
  @JsonKey(name: "exp")
  int exp;

  TokenBody({required this.sub, this.iat, required this.exp});

  factory TokenBody.fromJson(Map<String, dynamic> json) =>
      _$TokenBodyFromJson(json);

  Map<String, dynamic> toJson() => _$TokenBodyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TokenHeader {
  @JsonKey(name: "alg")
  String? alg;
  @JsonKey(name: "typ")
  String? typ;

  TokenHeader({this.alg, this.typ});

  factory TokenHeader.fromJson(Map<String, dynamic> json) =>
      _$TokenHeaderFromJson(json);

  Map<String, dynamic> toJson() => _$TokenHeaderToJson(this);
}
