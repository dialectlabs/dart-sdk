import 'dart:convert';
import 'dart:typed_data';

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
    return Uint8List.fromList(atob().codeUnits);
  }

  String encodeBase58() {
    final bytes = utf8.encode(this);
    return base58encode(bytes);
  }
}
