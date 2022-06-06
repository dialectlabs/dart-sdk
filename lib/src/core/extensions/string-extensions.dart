import 'dart:convert';

import 'package:pinenacl/ed25519.dart';
import 'package:solana/base58.dart';

extension StringExtensions on String {
  String atob() {
    final bytes = base64.decode(this);
    return utf8.decode(bytes);
  }

  String btoa() {
    final bytes = utf8.encode(this);
    return base64.encode(bytes);
  }

  Uint8List decodeBase64() {
    return atob().codeUnits.toUint8List();
  }

  String encodeBase58() {
    final bytes = utf8.encode(this);
    return base58encode(bytes);
  }
}
