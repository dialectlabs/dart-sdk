import 'dart:convert';

import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String sessionStorageTokenKey = 'dialect-auth-token';

class InMemoryTokenStore extends TokenStore {
  Token? _token;

  @override
  Future<Token?> get() {
    return Future.value(_token);
  }

  @override
  Future<Token> save(Token token) {
    _token = token;
    return Future.value(_token!);
  }
}

class SessionStorageTokenStore extends TokenStore {
  @override
  Future<Token?> get() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = prefs.getString(sessionStorageTokenKey);
      return Token.fromJson(JsonDecoder().convert(token));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Token> save(Token token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        sessionStorageTokenKey, JsonEncoder().convert(token.toJson()));
    return token;
  }
}

abstract class TokenStore {
  Future<Token?> get();
  Future<Token> save(Token token);
  static TokenStore createInMemory() {
    return InMemoryTokenStore();
  }

  static TokenStore createSession() {
    return SessionStorageTokenStore();
  }
}
