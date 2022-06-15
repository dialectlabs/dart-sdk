import 'package:dialect_sdk/src/sdk/errors.dart';

abstract class MessagingError extends DialectSdkError {
  MessagingError(
      {required String type, required String title, required String message})
      : super(type: type, title: title, message: message);
}

class ThreadAlreadyExistsError extends MessagingError {
  ThreadAlreadyExistsError()
      : super(
            type: "ThreadAlreadyExistsError",
            title: "Error",
            message: "You already have a thread with this address");
}
