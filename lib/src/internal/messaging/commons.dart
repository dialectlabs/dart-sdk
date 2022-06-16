import 'package:dialect_sdk/src/sdk/errors.dart';

T requireSingleMember<T>(List<T> members) {
  if (members.length != 1) {
    throw UnsupportedOperationError(
        title:
            'Unsupported operation\', \'Only P2P threads are supported: expected 2 members, but got ${members.length}');
  }
  return members.first;
}
