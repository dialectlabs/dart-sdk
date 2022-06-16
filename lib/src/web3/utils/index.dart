import 'dart:io';

import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

Future<TransactionDetails> waitForFinality(
    {required RpcClient client,
    required String transactionStr,
    Commitment commitment = Commitment.confirmed,
    int maxRetries = 10,
    int sleepDuration = 500}) async {
  try {
    return await waitForFinality_inner(
        client: client, transactionStr: transactionStr, commitment: commitment);
  } catch (e) {
    // TODO: log
    rethrow;
  }
}

Future<TransactionDetails> waitForFinality_inner(
    {required RpcClient client,
    required String transactionStr,
    Commitment commitment = Commitment.confirmed,
    int maxRetries = 10,
    int sleepDuration = 500}) async {
  TransactionDetails? transaction;
  for (var n = 0; n < maxRetries; n++) {
    transaction =
        await client.getTransaction(transactionStr, commitment: commitment);
    if (transaction != null) {
      return transaction;
    }
    sleep(Duration(milliseconds: sleepDuration));
  }
  throw Exception('Transaction failed to finalize');
}

class Finality {
  static const String _finalized = "finalized";
  static const String _confirmed = "confirmed";
  late String _finality;
  Finality.confirmed() {
    _finality = _confirmed;
  }

  Finality.finalized() {
    _finality = _finalized;
  }

  bool get confirmed => _finality == _confirmed;
  bool get finalized => _finality == _finalized;
}