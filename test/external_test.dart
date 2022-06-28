import 'package:solana_name_service/solana_name_service.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {});

    test('First Test', () async {
      final key = await findAccountByName("kdingens");
      print(key);
    });
  });
}
