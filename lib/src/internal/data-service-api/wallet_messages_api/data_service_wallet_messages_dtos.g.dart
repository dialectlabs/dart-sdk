// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_service_wallet_messages_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindWalletMessagesQueryDto _$FindWalletMessagesQueryDtoFromJson(
        Map<String, dynamic> json) =>
    FindWalletMessagesQueryDto(
      skip: json['skip'] as int?,
      take: json['take'] as int?,
      dappVerified: json['dappVerified'] as bool?,
    );

Map<String, dynamic> _$FindWalletMessagesQueryDtoToJson(
        FindWalletMessagesQueryDto instance) =>
    <String, dynamic>{
      'skip': instance.skip,
      'take': instance.take,
      'dappVerified': instance.dappVerified,
    };
