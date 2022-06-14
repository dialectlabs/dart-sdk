import 'package:dialect_sdk/src/core/extensions/string-extensions.dart';
import 'package:pinenacl/ed25519.dart';

extension ByteArrayExtensions on Uint8List {
  String encodeBase64() {
    var strings = map((e) => String.fromCharCode(e));
    var string = strings.join('');
    return string.btoa();
  }
}
