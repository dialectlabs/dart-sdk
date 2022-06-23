import 'package:dialect_sdk/src/sdk/errors.dart';
import 'package:dialect_sdk/src/web3/api/borsh/borsh-ext.dart';

SolanaError parseError(DialectSdkError error) {
  final message = error.message;
  print("PARSING $message");
  if (message == null) {
    throw UnknownError(details: [error]);
  }
  if (InsufficientFundsError.matchers.any((e) => e.hasMatch(message))) {
    throw InsufficientFundsError(details: [error]);
  }
  if (DisconnectedFromChainError.matchers.any((e) => e.hasMatch(message))) {
    throw DisconnectedFromChainError(details: [error]);
  }
  if (AccountAlreadyExistsError.matchers.any((e) => e.hasMatch(message))) {
    throw AccountAlreadyExistsError(details: [error]);
  }
  if (AccountNotFoundError.matchers.any((e) => e.hasMatch(message))) {
    throw AccountNotFoundError(details: [error]);
  }
  if (NotSignedError.matchers.any((e) => e.hasMatch(message))) {
    throw NotSignedError(details: [error]);
  }
  throw UnknownError(details: [error]);
}

Future<T> withErrorParsing<T>(Future<T> future) async {
  try {
    return await future;
  } on DialectSdkError catch (e) {
    throw parseError(e);
  }
}

class AccountAlreadyExistsError extends SolanaError {
  static List<RegExp> matchers = [
    RegExp(r'already in use'),
  ];

  AccountAlreadyExistsError({List<dynamic>? details})
      : super(
            type: "AccountAlreadyExistsError",
            title: 'Error',
            msg: 'Account already exists.',
            details: details);
}

class AccountNotFoundError extends SolanaError {
  static List<RegExp> matchers = [
    RegExp("${AccountNotFoundException().message}"),
  ];

  AccountNotFoundError({List<dynamic>? details})
      : super(
            type: "AccountNotFoundError",
            title: 'Error',
            msg: 'Account does not exist.',
            details: details);
}

class DisconnectedFromChainError extends SolanaError {
  static List<RegExp> matchers = [
    RegExp(r'Network request failed'),
  ];

  DisconnectedFromChainError({List<dynamic>? details})
      : super(
            type: "DisconnectedFromChainError",
            title: 'Lost connection to Solana blockchain',
            msg:
                'Having problems reaching Solana blockchain. Please try again later.',
            details: details);
}

class InsufficientFundsError extends SolanaError {
  static List<RegExp> matchers = [
    RegExp(
        r'Attempt to debit an account but found no record of a prior credit'),
    RegExp(r'(0x1)$', multiLine: true)
  ];

  InsufficientFundsError({List<dynamic>? details})
      : super(
            type: "InsufficientFundsError",
            title: 'Insufficient Funds',
            msg:
                'You do not have enough funds to complete this transaction. Please deposit more funds and try again.',
            details: details);
}

class NotSignedError extends SolanaError {
  static List<RegExp> matchers = [
    RegExp(r'User rejected the request'),
  ];

  NotSignedError({List<dynamic>? details})
      : super(
            type: "NotSignedError",
            title: 'Error',
            msg: 'You must sign the message to complete this action.',
            details: details);
}

abstract class SolanaError extends DialectSdkError {
  SolanaError(
      {required String type,
      required String title,
      required String msg,
      List<dynamic>? details})
      : super(type: type, title: title, message: msg, details: details);
}
