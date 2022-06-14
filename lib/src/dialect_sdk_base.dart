import 'package:solana/dto.dart';
import 'package:solana/solana.dart';

class Transaction {
  RecentBlockhash recentBlockhash;
  Message message;
  List<Ed25519HDKeyPair> signers;

  Transaction(
      {required this.recentBlockhash,
      required this.message,
      required this.signers});
}
