import 'package:dialect_sdk/src/auth/auth.interface.dart';
import 'package:dialect_sdk/src/auth/token_store.dart';
import 'package:dialect_sdk/src/internal/auth/token_utils.dart';

class CachedTokenProvider extends TokenProvider {
  TokenProvider delegate;
  TokenStore tokenStore;
  AuthTokens tokenUtils;

  Future<Token>? _delegateGetPromise;

  CachedTokenProvider(
      {required this.delegate,
      required this.tokenStore,
      required this.tokenUtils});

  @override
  Future<Token> get() async {
    final existingToken = await tokenStore.get();
    if (existingToken != null && !tokenUtils.isExpired(existingToken)) {
      _delegateGetPromise = null;
      return existingToken;
    }
    _delegateGetPromise ??=
        delegate.get().then((value) => tokenStore.save(value));
    return _delegateGetPromise!;
  }
}

class DefaultTokenProvider extends TokenProvider {
  Ed25519TokenSigner signer;
  Duration ttl;
  AuthTokens tokenUtils;

  DefaultTokenProvider(
      {required this.signer, required this.ttl, required this.tokenUtils});

  @override
  Future<Token> get() {
    return tokenUtils.generate(signer, ttl);
  }
}

abstract class TokenProvider {
  Future<Token> get();

  static TokenProvider create(
      {required Ed25519TokenSigner signer,
      Duration ttl = const Duration(hours: 1),
      TokenStore? tokenStore}) {
    final TokenStore tStore = tokenStore ?? InMemoryTokenStore();
    final tokenUtils = AuthTokensImpl();
    final defaultTokenProvider =
        DefaultTokenProvider(signer: signer, ttl: ttl, tokenUtils: tokenUtils);
    return CachedTokenProvider(
        delegate: defaultTokenProvider,
        tokenStore: tStore,
        tokenUtils: tokenUtils);
  }
}
