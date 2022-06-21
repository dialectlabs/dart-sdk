class AuthenticationError extends DialectSdkError {
  AuthenticationError({String? msg})
      : super(type: "AuthenticationError", title: "Error", message: msg);
}

class AuthorizationError extends DialectSdkError {
  AuthorizationError({String? msg})
      : super(type: "AuthorizationError", title: "Error", message: msg);
}

class BusinessContstraintViolationError extends DialectSdkError {
  BusinessContstraintViolationError({String? msg})
      : super(
            type: "BusinessContstraintViolationError",
            title: "Error",
            message: msg);
}

abstract class DialectCloudError extends DialectSdkError {
  DialectCloudError(
      {required String type,
      required String title,
      String? message,
      List<dynamic>? details})
      : super(type: type, title: title, message: message, details: details);
}

class DialectCloudUnreachableError extends DialectCloudError {
  DialectCloudUnreachableError({dynamic details})
      : super(
            type: "DialectCloudUnreachableError",
            title: "Lost connection to Dialect Cloud",
            message:
                "Having problems reaching Dialect Cloud. Please try again later.",
            details: details);
}

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

class ResourceAlreadyExistsError extends DialectSdkError {
  ResourceAlreadyExistsError({String? msg})
      : super(type: "ResourceAlreadyExistsError", title: "Error", message: msg);
}

class ResourceNotFoundError extends DialectSdkError {
  ResourceNotFoundError({String? msg})
      : super(type: "ResourceNotFoundError", title: "Error", message: msg);
}

class UnknownError extends DialectSdkError {
  UnknownError({dynamic details, String? msg})
      : super(
            type: "UnknownError",
            title: "Error",
            message: msg ?? "Something went wrong. Please try again later.",
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
