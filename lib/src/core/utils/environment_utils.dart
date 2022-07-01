class Env {
  static const String _privateKeyKey = "PRIVATE_KEY";
  static const String _rpcUrlKey = "RPC_URL";
  static const String _networkNameKey = "NETWORK_NAME";

  static String? get networkName {
    var name = String.fromEnvironment(_rpcUrlKey, defaultValue: "");
    return name.isEmpty ? null : name;
  }

  static String? get privateKey {
    var pkey = String.fromEnvironment(_privateKeyKey, defaultValue: "");
    return pkey.isEmpty ? null : pkey;
  }

  static String? get rpcUrl {
    var url = String.fromEnvironment(_networkNameKey, defaultValue: "");
    return url.isEmpty ? null : url;
  }
}
