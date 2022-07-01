import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

class OptionalUint8ListConverter
    implements JsonConverter<Uint8List?, List<int>?> {
  static Uint8ListConverter uint8ListConverter = const Uint8ListConverter();

  const OptionalUint8ListConverter();

  @override
  Uint8List? fromJson(List<int>? map) {
    if (map == null) {
      return null;
    }
    return uint8ListConverter.fromJson(map);
  }

  @override
  List<int>? toJson(Uint8List? list) {
    if (list == null) {
      return null;
    }
    return uint8ListConverter.toJson(list);
  }
}

class Uint8ListConverter implements JsonConverter<Uint8List, List<int>> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(List<int> list) {
    return Uint8List.fromList(list);
  }

  @override
  List<int> toJson(Uint8List object) {
    return object.toList();
  }
}
