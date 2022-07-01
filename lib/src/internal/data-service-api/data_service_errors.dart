import 'package:dialect_sdk/src/internal/data-service-api/data_service_api.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';

String createMessage(DataServiceApiError e) {
  return "${e.message}. ${e.requestId ?? ""}";
}

Future<T> withErrorParsing<T>(Future<T> future,
    {DialectSdkError Function(DataServiceApiError)?
        onResourceAlreadyExists}) async {
  try {
    return await future;
  } catch (e) {
    if (e is NetworkError) {
      throw DialectCloudUnreachableError();
    }
    if (e is DataServiceApiError) {
      if (e.statusCode == 401) {
        throw AuthenticationError(msg: createMessage(e));
      }
      if (e.statusCode == 403) {
        throw AuthorizationError(msg: createMessage(e));
      }
      if (e.statusCode == 404) {
        throw ResourceNotFoundError(msg: createMessage(e));
      }
      if (e.statusCode == 409) {
        if (onResourceAlreadyExists == null) {
          throw ResourceAlreadyExistsError(msg: createMessage(e));
        }
        throw onResourceAlreadyExists(e);
      }
      if (e.statusCode == 412) {
        throw BusinessContstraintViolationError(msg: createMessage(e));
      }
      throw UnknownError(details: [e], msg: createMessage(e));
    }
    throw UnknownError(details: [e]);
  }
}
