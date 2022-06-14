import 'package:dialect_sdk/src/cardinal/cardinal.dart';
import 'package:test/test.dart';

void main() {
  group('cardinal tests', () {
    setUp(() async {});

    test('retrieve account data on local', () async {
      try {
        fetchAddressFromTwitterHandle("aliquotchris");
      } catch (e) {
        print("error $e");
      }
    });
  });
}
