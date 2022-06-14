class DialectSdkError implements Exception {
  final String type;
  final String title;
  final String? message;
  final List<dynamic>? details;

  DialectSdkError(
      {required this.type, required this.title, this.message, this.details})
      : super();
}

class IllegalArgumentError extends DialectSdkError {
  IllegalArgumentError({required String title, String? msg, dynamic details})
      : super(
            type: "IllegalArgumentError",
            title: title,
            message: msg,
            details: details);
}

class IllegalStateError extends DialectSdkError {
  IllegalStateError({required String title, String? msg, dynamic details})
      : super(
            type: "IllegalStateError",
            title: title,
            message: msg,
            details: details);
}

class UnknownError extends DialectSdkError {
  UnknownError({dynamic details})
      : super(
            type: "UnknownError",
            title: "Error",
            message: "Something went wrong. Please try again later.",
            details: details);
}

class UnsupportedOperationError extends DialectSdkError {
  UnsupportedOperationError(
      {required String title, String? msg, dynamic details})
      : super(
            type: "UnsupportedOperationError",
            title: title,
            message: msg,
            details: details);
}
