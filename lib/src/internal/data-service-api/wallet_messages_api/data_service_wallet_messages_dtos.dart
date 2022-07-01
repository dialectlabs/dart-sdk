import 'package:json_annotation/json_annotation.dart';

part 'data_service_wallet_messages_dtos.g.dart';

@JsonSerializable(explicitToJson: true)
class FindWalletMessagesQueryDto {
  @JsonKey(name: "skip")
  final int? skip;
  @JsonKey(name: "take")
  final int? take;
  @JsonKey(name: "dappVerified")
  final bool? dappVerified;

  FindWalletMessagesQueryDto({this.skip, this.take, this.dappVerified});

  factory FindWalletMessagesQueryDto.fromJson(Map<String, dynamic> json) =>
      _$FindWalletMessagesQueryDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FindWalletMessagesQueryDtoToJson(this);
}
